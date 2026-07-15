extends Area2D

## Simple E-to-collect pickup for early resource loop testing.

@export var resource_id: String = "shells"
@export var amount: int = 1
@export var display_name: String = "Shell"

var _player_inside: bool = false
var _collected: bool = false

@onready var _label: Label = $Prompt


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if _label:
		_label.visible = false


func _process(_delta: float) -> void:
	if _collected or not _player_inside or RegionManager.is_busy():
		return
	if Input.is_action_just_pressed("interact"):
		_collect()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _label:
			_label.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _label:
			_label.visible = false


func _collect() -> void:
	_collected = true
	GameState.add_resource(resource_id, amount)
	if _label:
		_label.text = "+%d %s" % [amount, display_name]
		_label.visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.35)
	await tween.finished
	queue_free()
