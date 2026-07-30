extends CanvasLayer

## Lightweight prototype HUD: region name, exits, and key resources.

var _region_id: String = ""

@onready var _region_label: Label = $Panel/Margin/VBox/RegionLabel
@onready var _stats_label: Label = $Panel/Margin/VBox/StatsLabel
@onready var _exits_label: Label = $Panel/Margin/VBox/ExitsLabel
@onready var _hint_label: Label = $Panel/Margin/VBox/HintLabel


func _ready() -> void:
	add_to_group("region_hud")
	layer = 20
	GameState.resource_changed.connect(_on_resource_changed)
	GameState.money_changed.connect(_on_money_changed)
	_refresh()


func set_region(region_id: String) -> void:
	_region_id = region_id
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
	_exits_label.text = _format_exits(_region_id)
	_hint_label.text = "WASD move · E collect · Gold bars = region exits · F6 plays this scene, F5 starts Beach"


func _format_exits(region_id: String) -> String:
	if region_id.is_empty() or not RegionRegistry.has_region(region_id):
		return "Exits: —"
	var parts: PackedStringArray = []
	for neighbor_id in RegionRegistry.get_neighbors(region_id):
		var name := RegionRegistry.get_display_name(String(neighbor_id))
		if RegionRegistry.is_unlocked(String(neighbor_id)):
			parts.append(name)
		else:
			parts.append("%s (locked)" % name)
	return "Exits: " + ", ".join(parts)
