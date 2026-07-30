extends SceneTree

## Headless verification for the player movement-lock API.
## Run: godot --headless --path . --script res://tools/test_movement_lock.gd
##
## Uses runtime load() (not preload) so player.gd compiles after autoloads exist.
## Autoload globals are not visible to --script SceneTree mains at compile time,
## so RegionManager is resolved via /root.

const LOCK_A := &"test_a"
const LOCK_B := &"test_b"
const LOCK_UNKNOWN := &"never_requested"
const LOCK_REGION_TRANSITION := &"region_transition"

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var region_manager: Node = root.get_node_or_null("RegionManager")
	if region_manager == null:
		_fail_and_quit("RegionManager autoload missing under /root")
		return

	var player_scene: PackedScene = load("res://scenes/player/player.tscn")
	if player_scene == null:
		_fail_and_quit("failed to load player.tscn")
		return

	var player: CharacterBody2D = player_scene.instantiate()
	root.add_child(player)
	# One frame so @onready / _ready complete.
	await process_frame

	if player.get_script() == null:
		_fail_and_quit("player script failed to attach (check autoload compile errors)")
		return

	_assert(player.has_method("request_movement_lock"), "missing request_movement_lock")
	_assert(player.has_method("release_movement_lock"), "missing release_movement_lock")
	_assert(player.has_method("is_movement_locked"), "missing is_movement_locked")
	_assert(player.has_method("get_movement_lock_sources"), "missing get_movement_lock_sources")

	_assert(not bool(player.call("is_movement_locked")), "expected unlocked at start")
	_assert(Array(player.call("get_movement_lock_sources")).is_empty(), "expected empty sources at start")

	player.call("request_movement_lock", LOCK_A)
	_assert(bool(player.call("is_movement_locked")), "expected locked after request")
	_assert(_sources_equal(player.call("get_movement_lock_sources"), [LOCK_A]), "expected only LOCK_A")

	# Idempotent duplicate request.
	player.call("request_movement_lock", LOCK_A)
	_assert(_sources_equal(player.call("get_movement_lock_sources"), [LOCK_A]), "duplicate request should stay one lock")

	player.call("request_movement_lock", LOCK_B)
	_assert(_sources_equal(player.call("get_movement_lock_sources"), [LOCK_A, LOCK_B]), "expected both locks")

	# Releasing one source must not clear the other.
	player.call("release_movement_lock", LOCK_A)
	_assert(bool(player.call("is_movement_locked")), "still locked via LOCK_B")
	_assert(_sources_equal(player.call("get_movement_lock_sources"), [LOCK_B]), "expected only LOCK_B")

	# Safe copy: mutating the returned array must not mutate internal storage.
	var copy: Array = player.call("get_movement_lock_sources")
	copy.clear()
	_assert(_sources_equal(player.call("get_movement_lock_sources"), [LOCK_B]), "getter must return a safe copy")

	# Unknown release is a no-op (may warn).
	player.call("release_movement_lock", LOCK_UNKNOWN)
	_assert(_sources_equal(player.call("get_movement_lock_sources"), [LOCK_B]), "unknown release must not corrupt state")

	player.call("release_movement_lock", LOCK_B)
	_assert(not bool(player.call("is_movement_locked")), "expected unlocked after releasing last source")
	_assert(Array(player.call("get_movement_lock_sources")).is_empty(), "expected empty sources after unlock")

	# Locked movement clears velocity in physics.
	player.velocity = Vector2(50, 0)
	player.call("request_movement_lock", LOCK_A)
	player.call("_physics_process", 0.016)
	_assert(player.velocity == Vector2.ZERO, "locked physics must clear velocity")

	# RegionManager owns the region_transition source id constant.
	_assert(
		region_manager.get_script() != null,
		"RegionManager must have its script attached"
	)
	var constants: Dictionary = region_manager.get_script().get_script_constant_map()
	_assert(
		constants.get("LOCK_REGION_TRANSITION", &"") == LOCK_REGION_TRANSITION,
		"RegionManager.LOCK_REGION_TRANSITION must be &\"region_transition\""
	)

	# Centralized RegionManager helpers acquire/release on the registered player.
	player.call("release_movement_lock", LOCK_A)
	_assert(not bool(player.call("is_movement_locked")), "precondition: unlocked before RegionManager helper check")
	region_manager.call("_request_region_transition_lock")
	_assert(bool(player.call("is_movement_locked")), "RegionManager helper should lock player")
	_assert(
		_sources_equal(player.call("get_movement_lock_sources"), [LOCK_REGION_TRANSITION]),
		"expected region_transition source from RegionManager"
	)
	region_manager.call("_request_region_transition_lock")
	_assert(
		_sources_equal(player.call("get_movement_lock_sources"), [LOCK_REGION_TRANSITION]),
		"RegionManager duplicate acquire must stay idempotent"
	)
	region_manager.call("_finish_transition_failure")
	_assert(not bool(player.call("is_movement_locked")), "failure finish must release region_transition")
	_assert(not bool(region_manager.call("is_busy")), "failure finish must clear busy flag")

	if _failures == 0:
		print("test_movement_lock: PASS")
		quit(0)
	else:
		print("test_movement_lock: FAIL (%d assertion(s))" % _failures)
		quit(1)


func _fail_and_quit(message: String) -> void:
	push_error(message)
	print("test_movement_lock: FAIL — ", message)
	quit(1)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("ASSERT: %s" % message)
	print("ASSERT FAIL: ", message)


func _sources_equal(actual_variant: Variant, expected: Array) -> bool:
	var actual: Array = actual_variant
	if actual.size() != expected.size():
		return false
	for source in expected:
		if not actual.has(source):
			return false
	return true
