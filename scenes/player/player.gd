extends CharacterBody2D

@export var move_speed: float = 110.0

const BOB_HEIGHT := 1.5
const BOB_SPEED := 12.0

@onready var _sprite: Sprite2D = $Sprite

var _bob_time: float = 0.0
var _sprite_base_y: float = 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	_sprite_base_y = _sprite.position.y
	RegionManager.register_player(self)


func _physics_process(delta: float) -> void:
	if RegionManager.is_busy():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector.normalized() * move_speed if input_vector != Vector2.ZERO else Vector2.ZERO
	move_and_slide()

	if input_vector.x != 0.0:
		_sprite.flip_h = input_vector.x < 0.0

	# Simple walk bob until we have real animation frames.
	if velocity.length_squared() > 0.0:
		_bob_time += delta * BOB_SPEED
		_sprite.position.y = _sprite_base_y - absf(sin(_bob_time)) * BOB_HEIGHT
	else:
		_bob_time = 0.0
		_sprite.position.y = _sprite_base_y
