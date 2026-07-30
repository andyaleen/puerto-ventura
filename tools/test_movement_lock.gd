extends SceneTree

## Headless verification for the player movement-lock API.
## Run: godot --headless --path . --script res://tools/test_movement_lock.gd

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const LOCK_A := &"test_a"
const LOCK_B := &"test_b"
const LOCK_UNKNOWN := &"never_requested"

var _failures: int = 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player: CharacterBody2D = PLAYER_SCENE.instantiate()
	root.add_child(player)
	# One frame so @onready / _ready complete.
	await process_frame

	_assert(player.has_method("request_movement_lock"), "missing request_movement_lock")
	_assert(player.has_method("release_movement_lock"), "missing release_movement_lock")
	_assert(player.has_method("is_movement_locked"), "missing is_movement_locked")
	_assert(player.has_method("get_movement_lock_sources"), "missing get_movement_lock_sources")

	_assert(not player.is_movement_locked(), "expected unlocked at start")
	_assert(player.get_movement_lock_sources().is_empty(), "expected empty sources at start")

	player.request_movement_lock(LOCK_A)
	_assert(player.is_movement_locked(), "expected locked after request")
	_assert(_sources_equal(player.get_movement_lock_sources(), [LOCK_A]), "expected only LOCK_A")

	# Idempotent duplicate request.
	player.request_movement_lock(LOCK_A)
	_assert(_sources_equal(player.get_movement_lock_sources(), [LOCK_A]), "duplicate request should stay one lock")

	player.request_movement_lock(LOCK_B)
	_assert(_sources_equal(player.get_movement_lock_sources(), [LOCK_A, LOCK_B]), "expected both locks")

	# Releasing one source must not clear the other.
	player.release_movement_lock(LOCK_A)
	_assert(player.is_movement_locked(), "still locked via LOCK_B")
	_assert(_sources_equal(player.get_movement_lock_sources(), [LOCK_B]), "expected only LOCK_B")

	# Safe copy: mutating the returned array must not mutate internal storage.
	var copy: Array[StringName] = player.get_movement_lock_sources()
	copy.clear()
	_assert(_sources_equal(player.get_movement_lock_sources(), [LOCK_B]), "getter must return a safe copy")

	# Unknown release is a no-op (may warn).
	player.release_movement_lock(LOCK_UNKNOWN)
	_assert(_sources_equal(player.get_movement_lock_sources(), [LOCK_B]), "unknown release must not corrupt state")

	player.release_movement_lock(LOCK_B)
	_assert(not player.is_movement_locked(), "expected unlocked after releasing last source")
	_assert(player.get_movement_lock_sources().is_empty(), "expected empty sources after unlock")

	# Locked movement clears velocity / ignores input intent in physics.
	player.velocity = Vector2(50, 0)
	player.request_movement_lock(LOCK_A)
	player._physics_process(0.016)
	_assert(player.velocity == Vector2.ZERO, "locked physics must clear velocity")

	# RegionManager constant / helper ownership of region_transition id.
	_assert(
		RegionManager.LOCK_REGION_TRANSITION == &"region_transition",
		"RegionManager must expose region_transition lock id"
	)

	if _failures == 0:
		print("test_movement_lock: PASS")
		quit(0)
	else:
		print("test_movement_lock: FAIL (%d assertion(s))" % _failures)
		quit(1)


func _assert(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("ASSERT: %s" % message)
	print("ASSERT FAIL: ", message)


func _sources_equal(actual: Array[StringName], expected: Array[StringName]) -> bool:
	if actual.size() != expected.size():
		return false
	for source in expected:
		if not actual.has(source):
			return false
	return true
