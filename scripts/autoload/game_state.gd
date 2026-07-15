extends Node

## Persistent runtime state for Puerto Ventura.
## Region scenes load independently; this keeps player progress between maps.

signal money_changed(new_amount: int)
signal resource_changed(resource_id: String, new_amount: int)
signal restoration_completed(project_id: String)

const START_REGION := "beach"
const START_SPAWN := "default"

var current_region_id: String = START_REGION
var pending_spawn_id: String = START_SPAWN
var money: int = 0
var day: int = 1
var resources: Dictionary = {
	"wood": 0,
	"stone": 0,
	"fiber": 0,
	"shells": 0,
	"fish": 0,
}
## project_id -> bool completed
var restoration_progress: Dictionary = {}


func _ready() -> void:
	# Placeholder starter materials so early systems have something to show.
	resources["wood"] = 5
	resources["shells"] = 2


func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_changed.emit(money)


func add_resource(resource_id: String, amount: int) -> void:
	if not resources.has(resource_id):
		resources[resource_id] = 0
	resources[resource_id] = max(0, int(resources[resource_id]) + amount)
	resource_changed.emit(resource_id, resources[resource_id])


func get_resource(resource_id: String) -> int:
	return int(resources.get(resource_id, 0))


func is_restoration_complete(project_id: String) -> bool:
	return bool(restoration_progress.get(project_id, false))


func complete_restoration(project_id: String) -> void:
	if is_restoration_complete(project_id):
		return
	restoration_progress[project_id] = true
	restoration_completed.emit(project_id)


func set_travel_target(region_id: String, spawn_id: String) -> void:
	current_region_id = region_id
	pending_spawn_id = spawn_id
