extends Node2D

## Base behavior for every island region scene.
## Child scenes provide art, exits, spawns, and props.

@export var region_id: String = ""
@export var ground_color: Color = Color(0.45, 0.75, 0.55, 1)

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const HUD_SCENE := preload("res://scenes/systems/region_hud.tscn")

@onready var _ground: ColorRect = $Ground
@onready var _spawns: Node2D = $Spawns
@onready var _world_bounds: StaticBody2D = $WorldBounds


func _ready() -> void:
	if _ground:
		_ground.color = ground_color
	_ensure_bounds()
	_spawn_player()
	_spawn_hud()
	if region_id != "":
		GameState.current_region_id = region_id


func _spawn_player() -> void:
	var existing := get_tree().get_first_node_in_group("player")
	if existing:
		existing.queue_free()

	var player := PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = _resolve_spawn_position(GameState.pending_spawn_id)
	# Clear consumed spawn so accidental re-enters use default.
	GameState.pending_spawn_id = "default"


func _resolve_spawn_position(spawn_id: String) -> Vector2:
	if _spawns == null:
		return Vector2(640, 360)

	var exact := _spawns.get_node_or_null(spawn_id)
	if exact is Node2D:
		return (exact as Node2D).global_position

	var fallback := _spawns.get_node_or_null("default")
	if fallback is Node2D:
		return (fallback as Node2D).global_position

	return Vector2(640, 360)


func _spawn_hud() -> void:
	if get_tree().get_first_node_in_group("region_hud"):
		return
	var hud := HUD_SCENE.instantiate()
	add_child(hud)
	if hud.has_method("set_region"):
		hud.call("set_region", region_id)


func _ensure_bounds() -> void:
	# Soft invisible walls so the player stays inside the prototype playfield.
	if _world_bounds == null:
		return
	for child in _world_bounds.get_children():
		child.queue_free()

	var thickness := 40.0
	var width := 1280.0
	var height := 720.0
	_add_wall(Vector2(width * 0.5, -thickness * 0.5), Vector2(width + thickness * 2.0, thickness))
	_add_wall(Vector2(width * 0.5, height + thickness * 0.5), Vector2(width + thickness * 2.0, thickness))
	_add_wall(Vector2(-thickness * 0.5, height * 0.5), Vector2(thickness, height + thickness * 2.0))
	_add_wall(Vector2(width + thickness * 0.5, height * 0.5), Vector2(thickness, height + thickness * 2.0))


func _add_wall(center: Vector2, size: Vector2) -> void:
	var body := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	body.shape = shape
	body.position = center
	_world_bounds.add_child(body)
