extends SceneTree

## Headless baker: generates the Harbor tilemap scene.
## Run: godot --headless --path . --script res://tools/build_harbor_map.gd
## Inspired by the provided harbor plaza reference: central fountain, sandy
## square, dock/fish shop at the south edge, and whitewashed homes/shops.

const TILESET_PATH := "res://assets/tilesets/island_tileset.tres"
const OUT_PATH := "res://scenes/regions/harbor/harbor_map.tscn"

const W := 96
const H := 72

const T_GRASS := Vector2i(5, 0)
const T_DIRT := Vector2i(6, 0)
const T_SAND := Vector2i(8, 0)
const T_WATER := Vector2i(0, 0)
const T_STONE := Vector2i(7, 0)
const T_PLANK := Vector2i(7, 4)
const T_FLOWER := Vector2i(1, 6)
const T_FLOWER_WHITE := Vector2i(1, 9)

const T_TREE := Vector2i(23, 10)
const T_TREE_BASE := Vector2i(23, 11)
const T_BUSH := Vector2i(25, 9)
const T_FLOWER_BUSH := Vector2i(24, 9)
const T_LAMP := Vector2i(16, 7)
const T_BARREL := Vector2i(13, 7)
const T_SIGN := Vector2i(26, 8)

const BOX_WOOD := Vector2i(0, 25)
const BOX_STONE := Vector2i(3, 25)
const BOX_WHITE := Vector2i(6, 25)
const BOX_TERRACOTTA := Vector2i(12, 25)
const BOX_BLUE := Vector2i(15, 25)

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
	root.name = "HarborMap"
	root.y_sort_enabled = true

	_ground = _make_layer(root, "GroundLayer", tile_set, false, -10)
	_path = _make_layer(root, "PathLayer", tile_set, false, -8)
	_water = _make_layer(root, "WaterLayer", tile_set, false, -9)
	_props = _make_layer(root, "PropsLayer", tile_set, true, 0)
	_decor = _make_layer(root, "DecorLayer", tile_set, false, -7)
	_above = _make_layer(root, "AbovePlayerLayer", tile_set, true, 10)

	_paint_ground()
	_paint_paths()
	_paint_harbor()
	_paint_fountain()
	_paint_buildings()
	_paint_vegetation_and_detail()

	var packed := PackedScene.new()
	packed.pack(root)
	var err := ResourceSaver.save(packed, OUT_PATH)
	if err != OK:
		push_error("Failed to save Harbor map: %s" % err)
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
			if y < 10:
				tile = T_GRASS
			elif x < 7 and y < 46:
				tile = T_GRASS
			_ground.set_cell(Vector2i(x, y), 0, tile)
			# Ragged surf edge, so the harbor does not feel like a straight stripe.
			var wave_y := 55 + int(absf(sin(float(x) * 0.35)) * 2.0)
			if y >= wave_y:
				_water.set_cell(Vector2i(x, y), 0, T_WATER)


func _paint_paths() -> void:
	# Main sandy/stone promenade from beach exit to fountain and north district.
	_paint_rect(_path, Rect2i(45, 40, 8, 20), T_DIRT)
	_paint_rect(_path, Rect2i(42, 25, 14, 16), T_DIRT)
	_paint_rect(_path, Rect2i(44, 8, 9, 18), T_DIRT)
	_paint_rect(_path, Rect2i(16, 28, 30, 5), T_DIRT)
	_paint_rect(_path, Rect2i(56, 28, 24, 5), T_DIRT)
	_paint_rect(_path, Rect2i(19, 42, 62, 5), T_DIRT)

	# Broken cobblestones around the plaza and toward shops.
	for y in range(22, 48):
		for x in range(24, 72):
			var dx := absf(float(x - 48))
			var dy := absf(float(y - 35))
			if dx * dx / 460.0 + dy * dy / 135.0 < 1.0:
				if (x + y) % 3 != 0:
					_path.set_cell(Vector2i(x, y), 0, T_STONE)


func _paint_harbor() -> void:
	# Fishing pier, with a T-shaped working deck and a lower gangway.
	_paint_dock(Rect2i(43, 52, 9, 14))
	_paint_dock(Rect2i(51, 57, 28, 6))
	_paint_dock(Rect2i(76, 52, 6, 18))
	_paint_dock(Rect2i(78, 68, 13, 3))

	# Boat silhouette in the harbor.
	_paint_box(_props, 52, 64, 66, 67, BOX_WOOD)
	_paint_rect(_props, Rect2i(57, 61, 5, 3), BOX_WHITE + Vector2i(1, 1))

	# Pier posts, barrels, and crates.
	for p in [Vector2i(43, 52), Vector2i(51, 52), Vector2i(51, 63), Vector2i(79, 52), Vector2i(79, 69), Vector2i(90, 69)]:
		_props.set_cell(p, 0, T_BARREL)
	for p in [Vector2i(54, 56), Vector2i(70, 58), Vector2i(74, 62), Vector2i(84, 66)]:
		_props.set_cell(p, 0, BOX_WOOD + Vector2i(1, 1))


func _paint_fountain() -> void:
	var cx := 48
	var cy := 35
	for y in range(cy - 5, cy + 6):
		for x in range(cx - 5, cx + 6):
			var d := Vector2(x - cx, y - cy).length()
			if d < 5.2 and d > 3.2:
				_path.set_cell(Vector2i(x, y), 0, T_STONE)
			elif d <= 2.2:
				_props.set_cell(Vector2i(x, y), 0, Vector2i(3, 4))
	_props.set_cell(Vector2i(cx, cy), 0, Vector2i(3, 3))
	_props.set_cell(Vector2i(cx, cy - 1), 0, Vector2i(3, 3))


func _paint_buildings() -> void:
	# Top chapel/town-hall shape.
	_paint_box(_props, 39, 8, 55, 17, BOX_WHITE)
	_paint_box(_above, 40, 5, 54, 8, BOX_TERRACOTTA)

	# Left tackle/cafe shop near the beach.
	_paint_box(_props, 10, 26, 23, 36, BOX_WHITE)
	_paint_box(_above, 10, 23, 23, 26, BOX_TERRACOTTA)
	_paint_rect(_props, Rect2i(12, 37, 9, 1), T_PLANK)

	# Right-side homes and market.
	_paint_box(_props, 72, 18, 86, 29, BOX_WHITE)
	_paint_box(_above, 72, 15, 86, 18, BOX_TERRACOTTA)
	_paint_box(_props, 69, 36, 83, 47, BOX_WHITE)
	_paint_box(_above, 69, 33, 83, 36, BOX_TERRACOTTA)

	# Fisherman's shop by the harbor, using the blue palette as a visual anchor.
	_paint_box(_props, 63, 48, 78, 56, BOX_WHITE)
	_paint_box(_above, 63, 45, 78, 48, BOX_BLUE)
	_paint_rect(_props, Rect2i(64, 57, 13, 2), T_PLANK)

	# Market awning and notice board.
	_paint_box(_props, 58, 39, 66, 42, BOX_BLUE)
	_paint_box(_props, 47, 44, 52, 47, BOX_WOOD)
	_props.set_cell(Vector2i(48, 43), 0, T_SIGN)


func _paint_vegetation_and_detail() -> void:
	# Jungle pressure along the north/left edges.
	for x in range(0, W, 2):
		if x >= 42 and x <= 54:
			continue
		_props.set_cell(Vector2i(x, 3), 0, T_TREE)
	for y in range(4, 45, 2):
		if y >= 27 and y <= 34:
			continue
		_props.set_cell(Vector2i(3, y), 0, T_TREE)

	for y in range(8, 55):
		for x in range(5, 91):
			if _is_reserved_for_building_or_path(x, y):
				continue
			if (x * 23 + y * 11) % 41 == 0:
				_decor.set_cell(Vector2i(x, y), 0, T_BUSH)
			elif (x * 29 + y * 7) % 53 == 0:
				_decor.set_cell(Vector2i(x, y), 0, T_FLOWER_BUSH)
			elif (x * 17 + y * 19) % 67 == 0:
				_decor.set_cell(Vector2i(x, y), 0, T_FLOWER)
			elif (x * 31 + y * 5) % 71 == 0:
				_decor.set_cell(Vector2i(x, y), 0, T_FLOWER_WHITE)

	# Plaza lamps and wayfinding signs.
	for p in [Vector2i(38, 29), Vector2i(58, 29), Vector2i(38, 43), Vector2i(58, 43), Vector2i(42, 52), Vector2i(82, 45)]:
		_props.set_cell(p, 0, T_LAMP)


func _is_reserved_for_building_or_path(x: int, y: int) -> bool:
	if y >= 56:
		return true
	if x >= 39 and x <= 55 and y >= 5 and y <= 18:
		return true
	if x >= 10 and x <= 23 and y >= 23 and y <= 38:
		return true
	if x >= 69 and x <= 86 and y >= 15 and y <= 48:
		return true
	if x >= 63 and x <= 78 and y >= 45 and y <= 58:
		return true
	if x >= 22 and x <= 74 and y >= 22 and y <= 49:
		return true
	return false


func _paint_rect(layer: TileMapLayer, rect: Rect2i, tile: Vector2i) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			layer.set_cell(Vector2i(x, y), 0, tile)


func _paint_dock(rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			var cell := Vector2i(x, y)
			_water.erase_cell(cell)
			_path.set_cell(cell, 0, T_PLANK)


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
