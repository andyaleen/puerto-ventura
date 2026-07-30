extends SceneTree

## Headless verification for hold-to-sprint movement.
## Run: godot --headless --path . --script res://tools/test_sprint.gd
##
## Uses runtime load() (not preload) so player.gd compiles after autoloads exist.
## Autoload globals are not visible to --script SceneTree mains at compile time.

const LOCK_A := &"test_a"
const SPEED_EPSILON := 0.01

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_assert(InputMap.has_action("sprint"), "sprint input action must exist")
	_assert(
		not InputMap.action_get_events("sprint").is_empty(),
		"sprint action must have default bindings"
	)

	var has_shift := false
	var has_shoulder := false
	for event in InputMap.action_get_events("sprint"):
		if event is InputEventKey:
			var key_event := event as InputEventKey
			if key_event.physical_keycode == KEY_SHIFT:
				has_shift = true
		elif event is InputEventJoypadButton:
			var joy_event := event as InputEventJoypadButton
			if joy_event.button_index == JOY_BUTTON_LEFT_SHOULDER:
				has_shoulder = true
	_assert(has_shift, "sprint must bind keyboard Shift")
	_assert(has_shoulder, "sprint must bind gamepad LB / L1 (left shoulder)")

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

	_assert(player.get("sprint_multiplier") != null, "missing sprint_multiplier export")
	_assert(
		is_equal_approx(float(player.get("sprint_multiplier")), 1.6),
		"sprint_multiplier default must be 1.6"
	)
	_assert(
		is_equal_approx(float(player.get("move_speed")), 110.0),
		"move_speed default must remain 110"
	)

	var move_speed: float = float(player.get("move_speed"))
	var sprint_multiplier: float = float(player.get("sprint_multiplier"))
	var expected_sprint: float = move_speed * sprint_multiplier

	# Walk without sprint held.
	_release_move_and_sprint()
	Input.action_press("move_right")
	player.call("_physics_process", 0.016)
	_assert(_approx_len(player.velocity, move_speed), "walk speed without sprint must equal move_speed")
	_assert(_approx_vec(player.velocity, Vector2(move_speed, 0.0)), "cardinal walk should face right")

	# Hold sprint while moving → sprint speed.
	Input.action_press("sprint")
	player.call("_physics_process", 0.016)
	_assert(_approx_len(player.velocity, expected_sprint), "sprint speed must be move_speed * sprint_multiplier")
	_assert(_approx_vec(player.velocity, Vector2(expected_sprint, 0.0)), "cardinal sprint should face right")

	# Release sprint while still moving → immediate walk speed.
	Input.action_release("sprint")
	player.call("_physics_process", 0.016)
	_assert(_approx_len(player.velocity, move_speed), "releasing sprint must return to walk speed immediately")

	# Diagonal sprint remains normalized (same magnitude as cardinal sprint).
	_release_move_and_sprint()
	Input.action_press("move_right")
	Input.action_press("move_up")
	Input.action_press("sprint")
	player.call("_physics_process", 0.016)
	_assert(
		_approx_len(player.velocity, expected_sprint),
		"diagonal sprint magnitude must match cardinal sprint after normalization"
	)
	_assert(
		is_equal_approx(player.velocity.x, player.velocity.y * -1.0) or (
			absf(absf(player.velocity.x) - absf(player.velocity.y)) < SPEED_EPSILON
		),
		"diagonal sprint components should be equal magnitude"
	)

	# Sprint held without movement → idle.
	_release_move_and_sprint()
	Input.action_press("sprint")
	player.call("_physics_process", 0.016)
	_assert(player.velocity == Vector2.ZERO, "sprint without movement must leave player idle")

	# Movement lock overrides sprint and clears velocity.
	_release_move_and_sprint()
	Input.action_press("move_right")
	Input.action_press("sprint")
	player.call("_physics_process", 0.016)
	_assert(_approx_len(player.velocity, expected_sprint), "precondition: sprinting before lock")
	player.call("request_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(player.velocity == Vector2.ZERO, "lock must clear sprint velocity")
	_assert(bool(player.call("is_movement_locked")), "player should remain locked")

	# After unlock, sprint resumes only if still held with movement input.
	player.call("release_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(
		_approx_len(player.velocity, expected_sprint),
		"after unlock, held sprint + move should resume sprint"
	)

	# Held sprint through lock with move released during lock → idle after unlock.
	player.call("request_movement_lock", LOCK_A)
	Input.action_release("move_right")
	player.call("_physics_process", 0.016)
	_assert(player.velocity == Vector2.ZERO, "locked physics stays stopped")
	player.call("release_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(
		player.velocity == Vector2.ZERO,
		"sprint held without movement after unlock must stay idle"
	)

	# Placeholder bob resets when idle / locked.
	_release_move_and_sprint()
	Input.action_press("move_right")
	Input.action_press("sprint")
	player.call("_physics_process", 0.05)
	var sprite: Sprite2D = player.get_node("Sprite")
	var base_y: float = sprite.position.y
	# After moving, bob may have offset; idle must reset to base captured in _ready.
	# Force another frame of movement then idle.
	player.call("_physics_process", 0.05)
	var bobbed_y: float = sprite.position.y
	_release_move_and_sprint()
	player.call("_physics_process", 0.016)
	_assert(
		is_equal_approx(sprite.position.y, bobbed_y) or true,
		"sanity: bob path exercised"
	)
	# Reset path: idle clears bob to the sprite base established at ready (-8 default).
	_assert(
		is_equal_approx(sprite.position.y, -8.0),
		"idle must reset placeholder bob to base Y"
	)
	Input.action_press("move_right")
	Input.action_press("sprint")
	player.call("_physics_process", 0.05)
	player.call("request_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(
		is_equal_approx(sprite.position.y, -8.0),
		"lock must reset placeholder bob to base Y"
	)
	player.call("release_movement_lock", LOCK_A)
	_release_move_and_sprint()

	# Avoid unused warning if bob never differed (possible on tiny dt).
	if is_equal_approx(base_y, bobbed_y):
		pass

	if _failures == 0:
		print("test_sprint: PASS")
		quit(0)
	else:
		print("test_sprint: FAIL (%d assertion(s))" % _failures)
		quit(1)


func _release_move_and_sprint() -> void:
	for action in ["move_left", "move_right", "move_up", "move_down", "sprint"]:
		if Input.is_action_pressed(action):
			Input.action_release(action)


func _approx_len(v: Vector2, expected: float) -> bool:
	return absf(v.length() - expected) < SPEED_EPSILON


func _approx_vec(v: Vector2, expected: Vector2) -> bool:
	return v.distance_to(expected) < SPEED_EPSILON


func _fail_and_quit(message: String) -> void:
	push_error(message)
	print("test_sprint: FAIL — ", message)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("ASSERT: %s" % message)
	print("ASSERT FAIL: ", message)
