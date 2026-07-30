extends Node

## Loads one region scene at a time with a fade transition.
## Regions never all live in memory together.

signal transition_started(region_id: String)
signal transition_finished(region_id: String)

const FADE_OVERLAY_SCENE := preload("res://scenes/systems/fade_overlay.tscn")
const REGION_REGISTRY := preload("res://scripts/data/region_registry.gd")
const LOCK_REGION_TRANSITION := &"region_transition"

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
	# Scene changes free the previous player; re-acquire the lock on the new
	# instance while a transition is still in progress (e.g. during fade-in).
	if _is_transitioning:
		_request_region_transition_lock()


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
	_request_region_transition_lock()

	var tree := get_tree()

	await _fade.fade_out()
	GameState.set_travel_target(region_id, spawn_id)

	var scene_path := REGION_REGISTRY.get_scene_path(region_id)
	var err := tree.change_scene_to_file(scene_path)
	if err != OK:
		push_error("Failed to load region '%s' at %s (error %s)" % [region_id, scene_path, err])
		_finish_transition_failure()
		await _fade.fade_in()
		return

	# Wait one frame so the new region enters the tree and can place the player.
	await tree.process_frame
	await tree.process_frame

	# register_player() re-locks the new player while _is_transitioning is true.
	await _fade.fade_in()
	_finish_transition_success(region_id)


func is_busy() -> bool:
	return _is_transitioning


func _request_region_transition_lock() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	if _player.has_method("request_movement_lock"):
		_player.call("request_movement_lock", LOCK_REGION_TRANSITION)


func _release_region_transition_lock() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	if _player.has_method("release_movement_lock"):
		_player.call("release_movement_lock", LOCK_REGION_TRANSITION)


func _finish_transition_success(region_id: String) -> void:
	_release_region_transition_lock()
	_is_transitioning = false
	transition_finished.emit(region_id)


func _finish_transition_failure() -> void:
	_release_region_transition_lock()
	_is_transitioning = false
