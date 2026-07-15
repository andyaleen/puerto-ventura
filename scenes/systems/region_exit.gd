extends Area2D

## Place at map edges. Walking into this zone loads a neighboring region.

@export var target_region: String = ""
@export var target_spawn: String = "default"
@export var requires_unlocked: bool = true

var _triggered: bool = false


func _ready() -> void:
	collision_layer = 4 # exits
	collision_mask = 2 # player
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = false


func _on_body_entered(body: Node2D) -> void:
	if _triggered or RegionManager.is_busy():
		return
	if not body.is_in_group("player"):
		return
	if target_region.is_empty():
		push_warning("RegionExit '%s' has no target_region" % name)
		return
	if requires_unlocked and not RegionRegistry.is_unlocked(target_region):
		# Soft lock feedback for stub / late-game areas.
		print("The path to %s is not open yet." % RegionRegistry.get_display_name(target_region))
		return

	_triggered = true
	RegionManager.travel_to(target_region, target_spawn)
