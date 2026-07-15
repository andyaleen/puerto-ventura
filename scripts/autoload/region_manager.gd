extends Node

## Loads one region scene at a time with a fade transition.
## Regions never all live in memory together.

signal transition_started(region_id: String)
signal transition_finished(region_id: String)

const FADE_OVERLAY_SCENE := preload("res://scenes/systems/fade_overlay.tscn")
const REGION_REGISTRY := preload("res://scripts/data/region_registry.gd")

var _fade: CanvasLayer
var _is_transitioning: bool = false
var _player: CharacterBody2D


func _ready() -> void:
	_fade = FADE_OVERLAY_SCENE.instantiate()
	add_child(_fade)
	# Ensure fade renders above gameplay, including freshly loaded regions.
	_fade.layer = 100


func register_player(player: CharacterBody2D) -> void:
	_player = player


func get_player() -> CharacterBody2D:
	return _player


func travel_to(region_id: String, spawn_id: String = "default") -> void:
	if _is_transitioning:
		return
	if not REGION_REGISTRY.has_region(region_id):
		push_error("Unknown region: %s" % region_id)
		return

	_is_transitioning = true
	transition_started.emit(region_id)

	var tree := get_tree()
	if _player:
		_player.set_physics_process(false)

	await _fade.fade_out()
	GameState.set_travel_target(region_id, spawn_id)

	var scene_path := REGION_REGISTRY.get_scene_path(region_id)
	var err := tree.change_scene_to_file(scene_path)
	if err != OK:
		push_error("Failed to load region '%s' at %s (error %s)" % [region_id, scene_path, err])
		_is_transitioning = false
		if _player:
			_player.set_physics_process(true)
		await _fade.fade_in()
		return

	# Wait one frame so the new region enters the tree and can place the player.
	await tree.process_frame
	await tree.process_frame

	await _fade.fade_in()
	_is_transitioning = false
	transition_finished.emit(region_id)


func is_busy() -> bool:
	return _is_transitioning
