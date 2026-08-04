extends SceneTree

## Headless verification for player movement-state enum and animation contract.
## Run: godot --headless --path . --script res://tools/test_movement_state.gd
##
## Uses runtime load() (not preload) so player.gd compiles after autoloads exist.
## Autoload globals are not visible to --script SceneTree mains at compile time.

const LOCK_A := &"test_a"
const FACING_EPSILON := 0.001
const DIAGONAL_COMPONENT := 0.70710678118  # 1 / sqrt(2)

var _failures: int = 0
var _MovementState: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	if player_scene == null:
		_fail_and_quit("failed to load player.tscn")
		return

	var player: CharacterBody2D = player_scene.instantiate()
	root.add_child(player)
	await process_frame

	if player.get_script() == null:
		_fail_and_quit("player script failed to attach (check autoload compile errors)")
		return

	_MovementState = player.get_script().get_script_constant_map().get("MovementState", {})
	_assert(not _MovementState.is_empty(), "MovementState enum must exist on player script")
	_assert(_MovementState.has("IDLE"), "MovementState.IDLE required")
	_assert(_MovementState.has("WALKING"), "MovementState.WALKING required")
	_assert(_MovementState.has("SPRINTING"), "MovementState.SPRINTING required")
	_assert(_MovementState.has("LOCKED"), "MovementState.LOCKED required")
	_assert(not _MovementState.has("INTERACTING"), "INTERACTING must remain deferred")

	for method_name in [
		"get_movement_state",
		"get_movement_direction",
		"get_facing_direction",
		"is_walking",
		"is_sprinting",
		"is_movement_locked",
	]:
		_assert(player.has_method(method_name), "missing %s" % method_name)

	_release_move_and_sprint()
	player.call("_physics_process", 0.016)

	# 1. Initial state is IDLE.
	_assert(_state_eq(player, "IDLE"), "initial state must be IDLE")
	_assert(not bool(player.call("is_walking")), "initial is_walking must be false")
	_assert(not bool(player.call("is_sprinting")), "initial is_sprinting must be false")
	_assert(not bool(player.call("is_movement_locked")), "initial is_movement_locked must be false")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.ZERO), "initial movement direction must be zero")
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.RIGHT), "default facing should be right")

	# 2. Directional input without sprint → WALKING.
	Input.action_press("move_right")
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "WALKING"), "move without sprint must be WALKING")
	_assert(bool(player.call("is_walking")), "is_walking must match WALKING")
	_assert(not bool(player.call("is_sprinting")), "is_sprinting must be false while walking")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.RIGHT), "walk right movement direction")
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.RIGHT), "walk right facing")

	# 3. Directional input with sprint → SPRINTING.
	Input.action_press("sprint")
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "SPRINTING"), "move with sprint must be SPRINTING")
	_assert(bool(player.call("is_sprinting")), "is_sprinting must match SPRINTING")
	_assert(not bool(player.call("is_walking")), "is_walking must be false while sprinting")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.RIGHT), "sprint keeps movement direction")

	# 4. Sprint held without movement → IDLE.
	Input.action_release("move_right")
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "IDLE"), "sprint without movement must be IDLE")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.ZERO), "idle movement direction must be zero")
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.RIGHT), "facing survives idle")

	# 6. Facing survives transition to idle (from left).
	_release_move_and_sprint()
	Input.action_press("move_left")
	player.call("_physics_process", 0.016)
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.LEFT), "precondition: facing left")
	Input.action_release("move_left")
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "IDLE"), "released movement is IDLE")
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.LEFT), "facing survives transition to idle")

	# 8. Vertical movement updates facing.
	Input.action_press("move_up")
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "WALKING"), "vertical move is WALKING")
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.UP), "vertical up updates facing")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.UP), "vertical up movement direction")
	var sprite: Sprite2D = player.get_node("Sprite")
	_assert(sprite.flip_h == true, "pure vertical keeps last horizontal flip_h (left)")

	Input.action_release("move_up")
	Input.action_press("move_down")
	player.call("_physics_process", 0.016)
	_assert(_vec_eq(player.call("get_facing_direction"), Vector2.DOWN), "vertical down updates facing")

	# 9. Diagonal movement follows normalized deterministic rule.
	_release_move_and_sprint()
	Input.action_press("move_right")
	Input.action_press("move_up")
	player.call("_physics_process", 0.016)
	var expected_diag := Vector2(DIAGONAL_COMPONENT, -DIAGONAL_COMPONENT)
	_assert(
		_vec_eq(player.call("get_facing_direction"), expected_diag),
		"diagonal facing must be normalized (right+up)"
	)
	_assert(
		_vec_eq(player.call("get_movement_direction"), expected_diag),
		"diagonal movement direction must match normalized input"
	)
	_assert(sprite.flip_h == false, "diagonal with +x should clear flip_h")

	# 5 + 7. Any movement lock → LOCKED, zero movement direction; facing survives.
	var facing_before_lock: Vector2 = player.call("get_facing_direction")
	player.call("request_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "LOCKED"), "active lock must produce LOCKED")
	_assert(bool(player.call("is_movement_locked")), "is_movement_locked remains compatible")
	_assert(not bool(player.call("is_walking")), "locked is_walking must be false")
	_assert(not bool(player.call("is_sprinting")), "locked is_sprinting must be false")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.ZERO), "lock clears movement direction")
	_assert(
		_vec_eq(player.call("get_facing_direction"), facing_before_lock),
		"facing survives lock acquisition"
	)
	_assert(player.velocity == Vector2.ZERO, "locked physics clears velocity")

	# Facing survives lock release (still holding diagonal input → resumes walking).
	player.call("release_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "WALKING"), "unlock with held move resumes WALKING")
	_assert(
		_vec_eq(player.call("get_facing_direction"), expected_diag),
		"facing survives lock release"
	)

	# Lock while idle still reports LOCKED and preserves prior facing.
	_release_move_and_sprint()
	player.call("_physics_process", 0.016)
	var idle_facing: Vector2 = player.call("get_facing_direction")
	player.call("request_movement_lock", LOCK_A)
	_assert(_state_eq(player, "LOCKED"), "lock without physics still reports LOCKED via live derive")
	_assert(_vec_eq(player.call("get_movement_direction"), Vector2.ZERO), "locked direction zero without physics")
	player.call("_physics_process", 0.016)
	_assert(_vec_eq(player.call("get_facing_direction"), idle_facing), "facing survives idle lock")
	player.call("release_movement_lock", LOCK_A)

	# is_walking / is_sprinting agree with get_movement_state after sprint+lock edge cases.
	_release_move_and_sprint()
	Input.action_press("move_right")
	Input.action_press("sprint")
	player.call("_physics_process", 0.016)
	_assert(_state_eq(player, "SPRINTING"), "precondition sprinting")
	_assert(bool(player.call("is_sprinting")) == _state_eq(player, "SPRINTING"), "is_sprinting agrees")
	_assert(bool(player.call("is_walking")) == _state_eq(player, "WALKING"), "is_walking agrees")
	player.call("request_movement_lock", LOCK_A)
	_assert(_state_eq(player, "LOCKED"), "lock overrides sprint to LOCKED")
	_assert(not bool(player.call("is_sprinting")), "is_sprinting false when LOCKED")
	_assert(not bool(player.call("is_walking")), "is_walking false when LOCKED")
	player.call("release_movement_lock", LOCK_A)
	_release_move_and_sprint()

	if _failures == 0:
		print("test_movement_state: PASS")
		quit(0)
	else:
		print("test_movement_state: FAIL (%d assertion(s))" % _failures)
		quit(1)


func _state_eq(player: Object, name: String) -> bool:
	var actual: Variant = player.call("get_movement_state")
	return int(actual) == int(_MovementState[name])


func _vec_eq(actual_variant: Variant, expected: Vector2) -> bool:
	var actual: Vector2 = actual_variant
	return actual.distance_to(expected) < FACING_EPSILON


func _release_move_and_sprint() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "sprint"]:
		if Input.is_action_pressed(action):
			Input.action_release(action)


func _fail_and_quit(message: String) -> void:
	push_error(message)
	print("test_movement_state: FAIL — ", message)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("ASSERT: %s" % message)
	print("ASSERT FAIL: ", message)
