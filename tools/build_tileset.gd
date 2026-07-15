extends SceneTree

## Headless baker: builds the shared island TileSet from the Kenney sheets.
## Run: godot --headless --path . --script res://tools/build_tileset.gd

const TERRAIN_TEXTURE := "res://assets/tilesheets/roguelike_terrain.png"
const OUT_PATH := "res://assets/tilesets/island_tileset.tres"

## Atlas coords (16x16 tiles, 1px separation) that block movement.
const SOLID_TILES: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0),          # ocean water
	Vector2i(23, 10), Vector2i(23, 11),      # transparent-bg trees
	Vector2i(0, 25), Vector2i(1, 25), Vector2i(2, 25),  # brown box (walls/wreck)
	Vector2i(0, 26), Vector2i(1, 26), Vector2i(2, 26),
	Vector2i(0, 30), Vector2i(1, 30), Vector2i(2, 30),
	Vector2i(12, 25), Vector2i(13, 25), Vector2i(14, 25),  # terracotta box (roof)
	Vector2i(12, 26), Vector2i(13, 26), Vector2i(14, 26),
	Vector2i(12, 30), Vector2i(13, 30), Vector2i(14, 30),
]


func _init() -> void:
	var texture: Texture2D = load(TERRAIN_TEXTURE)
	if texture == null:
		push_error("Terrain texture not imported yet: " + TERRAIN_TEXTURE)
		quit(1)
		return

	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.separation = Vector2i(1, 1)
	atlas.texture_region_size = Vector2i(16, 16)

	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(16, 16)
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1) # "world" layer
	tile_set.set_physics_layer_collision_mask(0, 0)
	tile_set.add_source(atlas, 0)

	# Register every grid cell as a paintable tile so the editor can use the
	# full sheet later, not just what the generated maps consume.
	var grid := atlas.get_atlas_grid_size()
	for y in grid.y:
		for x in grid.x:
			var coords := Vector2i(x, y)
			if not atlas.has_tile(coords):
				atlas.create_tile(coords)

	var full_rect := PackedVector2Array([
		Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8),
	])
	for coords in SOLID_TILES:
		var data := atlas.get_tile_data(coords, 0)
		data.add_collision_polygon(0)
		data.set_collision_polygon_points(0, 0, full_rect)

	DirAccess.make_dir_recursive_absolute("res://assets/tilesets")
	var err := ResourceSaver.save(tile_set, OUT_PATH)
	if err != OK:
		push_error("Failed to save tileset: %s" % err)
		quit(1)
		return
	print("Saved ", OUT_PATH, " with ", grid.x * grid.y, " tiles")
	quit(0)
