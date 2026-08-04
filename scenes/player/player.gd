extends CharacterBody2D

## Milestone 1 locomotion states derivable by the player controller.
## INTERACTING is deferred until an interaction system owns that mode.
enum MovementState {
	IDLE,
	WALKING,
	SPRINTING,
	LOCKED,
}

@export var move_speed: float = 110.0
@export var sprint_multiplier: float = 1.6

const BOB_HEIGHT := 1.5
const BOB_SPEED := 12.0

@onready var _sprite: Sprite2D = $Sprite

var _bob_time: float = 0.0
var _sprite_base_y: float = 0.0
## Active movement-lock sources keyed by StringName. Values are unused sentinels.
var _movement_locks: Dictionary = {}
## Last non-zero facing (normalized). Persists through idle and locks.
var _facing_direction: Vector2 = Vector2.RIGHT


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	_sprite_base_y = _sprite.position.y
	RegionManager.register_player(self)


func request_movement_lock(source: StringName) -> void:
	_movement_locks[source] = true


func release_movement_lock(source: StringName) -> void:
	if not _movement_locks.has(source):
		push_warning("release_movement_lock: unknown source '%s'" % String(source))
		return
	_movement_locks.erase(source)


func is_movement_locked() -> bool:
	return not _movement_locks.is_empty()


func get_movement_lock_sources() -> Array[StringName]:
	var sources: Array[StringName] = []
	for key in _movement_locks.keys():
		sources.append(key as StringName)
	return sources


func get_movement_state() -> MovementState:
	return _derive_movement_state(
		is_movement_locked(),
		_read_move_input(),
		Input.is_action_pressed("sprint")
	)


func get_movement_direction() -> Vector2:
	if is_movement_locked():
		return Vector2.ZERO
	var move_input := _read_move_input()
	if move_input == Vector2.ZERO:
		return Vector2.ZERO
	return move_input.normalized()


func get_facing_direction() -> Vector2:
	return _facing_direction


func is_walking() -> bool:
	return get_movement_state() == MovementState.WALKING


func is_sprinting() -> bool:
	return get_movement_state() == MovementState.SPRINTING


func _physics_process(delta: float) -> void:
	var locked := is_movement_locked()
	var move_input := _read_move_input()
	var sprint_held := Input.is_action_pressed("sprint")
	var state := _derive_movement_state(locked, move_input, sprint_held)
	var is_moving := state == MovementState.WALKING or state == MovementState.SPRINTING
	var sprinting := state == MovementState.SPRINTING

	if locked:
		velocity = Vector2.ZERO
		_reset_walk_bob()
		move_and_slide()
		return

	if is_moving:
		var direction := move_input.normalized()
		_facing_direction = direction
		# Placeholder flip remains horizontal-only until 8-directional frames exist.
		if move_input.x != 0.0:
			_sprite.flip_h = move_input.x < 0.0
		var speed := move_speed * sprint_multiplier if sprinting else move_speed
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Placeholder bob consumes the same derived WALKING / SPRINTING state.
	if is_moving:
		var bob_speed := BOB_SPEED * sprint_multiplier if sprinting else BOB_SPEED
		_bob_time += delta * bob_speed
		_sprite.position.y = _sprite_base_y - absf(sin(_bob_time)) * BOB_HEIGHT
	else:
		_reset_walk_bob()


func _read_move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _derive_movement_state(locked: bool, move_input: Vector2, sprint_held: bool) -> MovementState:
	# Precedence: LOCKED → SPRINTING → WALKING → IDLE.
	# INTERACTING is deferred (no owning interaction system yet).
	if locked:
		return MovementState.LOCKED
	if move_input == Vector2.ZERO:
		return MovementState.IDLE
	if sprint_held:
		return MovementState.SPRINTING
	return MovementState.WALKING


func _reset_walk_bob() -> void:
	_bob_time = 0.0
	if _sprite:
		_sprite.position.y = _sprite_base_y
