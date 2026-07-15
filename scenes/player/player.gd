extends CharacterBody2D

@export var move_speed: float = 180.0

@onready var _anim_label: Label = $DebugLabel


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	RegionManager.register_player(self)


func _physics_process(_delta: float) -> void:
	if RegionManager.is_busy():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector.normalized() * move_speed if input_vector != Vector2.ZERO else Vector2.ZERO
	move_and_slide()

	if _anim_label:
		_anim_label.rotation = 0.0
