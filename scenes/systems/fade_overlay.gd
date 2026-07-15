extends CanvasLayer

signal fade_completed

@export var fade_duration: float = 0.35

@onready var _veil: ColorRect = $Veil


func _ready() -> void:
	layer = 100
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.color = Color(0, 0, 0, 0)
	_veil.set_anchors_preset(Control.PRESET_FULL_RECT)


func fade_out() -> void:
	_veil.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween := create_tween()
	tween.tween_property(_veil, "color:a", 1.0, fade_duration)
	await tween.finished
	fade_completed.emit()


func fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_veil, "color:a", 0.0, fade_duration)
	await tween.finished
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_completed.emit()
