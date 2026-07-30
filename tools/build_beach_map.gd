extends SceneTree

## Headless baker: generates the Beach tilemap scene (ground + props layers).
## Run: godot --headless --path . --script res://tools/build_beach_map.gd
## Regenerate any time; gameplay nodes (exits, spawns, pickups) stay in beach.tscn.

const TILESET_PATH := "res://assets/tilesets/island_tileset.tres"
const OUT_PATH := "res://scenes/regions/beach/beach_map.tscn"

const W := 80
const H := 45
const GRASS_END := 19   # rows 0..18 grass
const SAND_END := 34    # rows 19..33 sand, 34+ water

const T_GRASS := Vector2i(5, 0)
const T_DIRT := Vector2i(6, 0)
const T_SAND := Vector2i(8, 0)
const T_WATER := Vector2i(0, 0)
const T_PLANK := Vector2i(7, 4)
## Trees/bushes with transparent backgrounds so they blend with any ground.
const TREES: Array[Vector2i] = [
	Vector2i(23, 10), Vector2i(23, 11),
]
const BUSHES: Array[Vector2i] = [
	Vector2i(25, 9), Vector2i(24, 9),
]

const BOX_WOOD := Vector2i(0, 25)       # brown 9-patch (walls, shipwreck)
const BOX_TERRACOTTA := Vector2i(12, 25) # orange 9-patch (roof)

var _ground: TileMapLayer
var _path: TileMapLayer
var _water: TileMapLayer
var _props: TileMapLayer
var _decor: TileMapLayer
var _above: TileMapLayer


func _init() -> void:
	var tile_set: TileSet = load(TILESET_PATH)
	if tile_set == null:
		push_error("TileSet missing; run build_tileset.gd first")
		quit(1)
		return

	var root := Node2D.new()
	root.name = "BeachMap"
	root.y_sort_enabled = true

	_ground = _make_layer(root, "GroundLayer", tile_set, false, -10)
	_path = _make_layer(root, "PathLayer", tile_set, false, -8)
	_water = _make_layer(root, "WaterLayer", tile_set, false, -9)
	_props = _make_layer(root, "PropsLayer", tile_set, true, 0)
	_decor = _make_layer(root, "DecorLayer", tile_set, false, -7)
	_above = _make_layer(root, "AbovePlayerLayer", tile_set, true, 10)

	_paint_ground()
	_paint_path_and_dock()
	_paint_vegetation()
	_paint_box(_above, 11, 17, 18, 19, BOX_TERRACOTTA) # cottage roof
	_paint_box(_props, 11, 20, 18, 22, BOX_WOOD)       # cottage walls
	_paint_box(_props, 65, 27, 73, 30, BOX_WOOD)       # shipwreck

	var packed := PackedScene.new()
	packed.pack(root)
	var err := ResourceSaver.save(packed, OUT_PATH)
	if err != OK:
		push_error("Failed to save beach map: %s" % err)
		quit(1)
		return
	print("Saved ", OUT_PATH)
	quit(0)


func _make_layer(
	root: Node,
	layer_name: String,
	tile_set: TileSet,
	y_sort: bool,
	z: int
) -> TileMapLayer:
	var layer := TileMapLayer.new()
	layer.name = layer_name
	layer.tile_set = tile_set
	layer.y_sort_enabled = y_sort
	layer.z_index = z
	root.add_child(layer)
	layer.owner = root
	return layer


func _paint_ground() -> void:
	for y in H:
		for x in W:
			var tile := T_SAND
			if y < GRASS_END:
				tile = T_GRASS
			_ground.set_cell(Vector2i(x, y), 0, tile)
			if y >= SAND_END:
				_water.set_cell(Vector2i(x, y), 0, T_WATER)


func _paint_path_and_dock() -> void:
	# Dirt path from the north exit down to the shore.
	for y in range(0, SAND_END):
		for x in range(39, 42):
			_path.set_cell(Vector2i(x, y), 0, T_DIRT)
	# Wooden dock reaching into the ocean (walkable: planks replace water).
	for y in range(31, 39):
		for x in range(56, 61):
			_water.erase_cell(Vector2i(x, y))
			_path.set_cell(Vector2i(x, y), 0, T_PLANK)


func _is_reserved(x: int, y: int) -> bool:
	if x >= 38 and x <= 43:          # path + north exit corridor
		return true
	if x >= 10 and x <= 19 and y >= 16 and y <= 23:  # cottage + margin
		return true
	return false


func _paint_vegetation() -> void:
	# Dense tree line along the top edge, leaving the exit gap open.
	for y in 2:
		for x in range(0, W, 2):
			if x >= 36 and x <= 44:
				continue
			_props.set_cell(Vector2i(x, y), 0, TREES[(x / 2 + y) % TREES.size()])

	for y in range(2, GRASS_END):
		for x in range(1, W - 1):
			if _is_reserved(x, y):
				continue
			if (x * 31 + y * 17) % 29 == 0:
				_props.set_cell(Vector2i(x, y), 0, TREES[(x + y) % TREES.size()])
			elif (x * 13 + y * 7) % 31 == 0:
				_decor.set_cell(Vector2i(x, y), 0, BUSHES[(x + y) % BUSHES.size()])


func _paint_box(layer: TileMapLayer, x0: int, y0: int, x1: int, y1: int, origin: Vector2i) -> void:
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			var col := 1
			if x == x0:
				col = 0
			elif x == x1:
				col = 2
			var row := 1
			if y == y0:
				row = 0
			elif y == y1:
				row = 5
			layer.set_cell(Vector2i(x, y), 0, origin + Vector2i(col, row))
