extends CharacterBody2D

@export var move_speed: float = 110.0
@export var sprint_multiplier: float = 1.6

const BOB_HEIGHT := 1.5
const BOB_SPEED := 12.0

@onready var _sprite: Sprite2D = $Sprite

var _bob_time: float = 0.0
var _sprite_base_y: float = 0.0
## Active movement-lock sources keyed by StringName. Values are unused sentinels.
var _movement_locks: Dictionary = {}


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


func _physics_process(delta: float) -> void:
	if is_movement_locked():
		velocity = Vector2.ZERO
		_reset_walk_bob()
		move_and_slide()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_moving := input_vector != Vector2.ZERO
	# Hold-to-sprint: only while directional input is present. Locks ignore sprint above.
	var is_sprinting := is_moving and Input.is_action_pressed("sprint")
	var speed := move_speed * sprint_multiplier if is_sprinting else move_speed
	velocity = input_vector.normalized() * speed if is_moving else Vector2.ZERO
	move_and_slide()

	if input_vector.x != 0.0:
		_sprite.flip_h = input_vector.x < 0.0

	# Placeholder bob; sprint uses the exported multiplier as cadence scale (no extra magic).
	if velocity.length_squared() > 0.0:
		var bob_speed := BOB_SPEED * sprint_multiplier if is_sprinting else BOB_SPEED
		_bob_time += delta * bob_speed
		_sprite.position.y = _sprite_base_y - absf(sin(_bob_time)) * BOB_HEIGHT
	else:
		_reset_walk_bob()


func _reset_walk_bob() -> void:
	_bob_time = 0.0
	if _sprite:
		_sprite.position.y = _sprite_base_y
