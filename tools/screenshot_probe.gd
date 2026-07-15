extends Node

## Temporary visual check: loads the Beach, walks the player around,
## and saves screenshots to docs/. Run:
## godot --path . res://tools/screenshot_probe.tscn


func _ready() -> void:
	var beach: Node = load("res://scenes/regions/beach/beach.tscn").instantiate()
	add_child(beach)
	await get_tree().create_timer(0.8).timeout
	_save("screenshot_spawn.png")

	Input.action_press("move_right")
	await get_tree().create_timer(1.6).timeout
	Input.action_release("move_right")
	Input.action_press("move_up")
	await get_tree().create_timer(2.2).timeout
	Input.action_release("move_up")
	await get_tree().create_timer(0.4).timeout
	_save("screenshot_walk.png")

	var player := RegionManager.get_player()
	player.global_position = Vector2(930, 480)
	await get_tree().create_timer(0.8).timeout
	_save("screenshot_dock.png")

	get_tree().quit()


func _save(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	image.save_png("res://docs/" + file_name)
	print("saved ", file_name)
