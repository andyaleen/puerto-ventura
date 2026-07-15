extends CanvasLayer

## Lightweight prototype HUD: region name + key resources.

@onready var _region_label: Label = $Panel/Margin/VBox/RegionLabel
@onready var _stats_label: Label = $Panel/Margin/VBox/StatsLabel
@onready var _hint_label: Label = $Panel/Margin/VBox/HintLabel


func _ready() -> void:
	add_to_group("region_hud")
	layer = 20
	GameState.resource_changed.connect(_on_resource_changed)
	GameState.money_changed.connect(_on_money_changed)
	_refresh()


func set_region(region_id: String) -> void:
	if RegionRegistry.has_region(region_id):
		_region_label.text = RegionRegistry.get_display_name(region_id)
	else:
		_region_label.text = region_id
	_refresh()


func _on_resource_changed(_resource_id: String, _amount: int) -> void:
	_refresh()


func _on_money_changed(_amount: int) -> void:
	_refresh()


func _refresh() -> void:
	_stats_label.text = "Day %d  |  $%d  |  Wood %d  ·  Stone %d  ·  Shells %d  ·  Fish %d" % [
		GameState.day,
		GameState.money,
		GameState.get_resource("wood"),
		GameState.get_resource("stone"),
		GameState.get_resource("shells"),
		GameState.get_resource("fish"),
	]
	_hint_label.text = "WASD move · E collect · Walk into gold exits to travel"
