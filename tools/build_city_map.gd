extends SceneTree

## Headless baker for Idyllic City Center.
## Run: godot --headless --path . --script res://tools/build_city_map.gd
## The city is the island crossroads: five roads radiate from a civic plaza
## toward Beach, Harbor, Jungle, Mining, and Desert.

const TILESET_PATH := "res://assets/tilesets/island_tileset.tres"
const OUT_PATH := "res://scenes/regions/city/city_map.tscn"

const W := 96
const H := 72
const PLAZA := Vector2i(48, 36)

const T_GRASS := Vector2i(5, 0)
const T_DIRT := Vector2i(6, 0)
const T_WATER := Vector2i(0, 0)
const T_STONE := Vector2i(7, 0)
const T_PLANK := Vector2i(7, 4)
const T_FLOWER := Vector2i(1, 6)
const T_FLOWER_WHITE := Vector2i(1, 9)

const T_TREE := Vector2i(23, 10)
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
	root.name = "CityMap"
	root.y_sort_enabled = true

	_ground = _make_layer(root, "GroundLayer", tile_set, false, -10)
	_path = _make_layer(root, "PathLayer", tile_set, false, -8)
	_water = _make_layer(root, "WaterLayer", tile_set, false, -9)
	_props = _make_layer(root, "PropsLayer", tile_set, true, 0)
	_decor = _make_layer(root, "DecorLayer", tile_set, false, -7)
	_above = _make_layer(root, "AbovePlayerLayer", tile_set, true, 10)

	_paint_ground()
	_paint_canal()
	_paint_roads_and_plaza()
	_paint_buildings()
	_paint_fountain()
	_paint_gardens_and_details()

	var packed := PackedScene.new()
	packed.pack(root)
	var err := ResourceSaver.save(packed, OUT_PATH)
	if err != OK:
		push_error("Failed to save City map: %s" % err)
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
			_ground.set_cell(Vector2i(x, y), 0, T_GRASS)


func _paint_canal() -> void:
	# A narrow restored canal runs through the eastern district.
	for y in range(6, H):
		var center_x := 79 + int(round(sin(float(y) * 0.23) * 2.0))
		for x in range(center_x - 1, center_x + 2):
			_water.set_cell(Vector2i(x, y), 0, T_WATER)


func _paint_roads_and_plaza() -> void:
	# Five routes mirror the annotated overworld connection points.
	_paint_road_line(PLAZA, Vector2i(10, H - 1), 2, T_DIRT)  # Beach
	_paint_road_line(PLAZA, Vector2i(48, H - 1), 2, T_STONE) # Harbor
	_paint_road_line(PLAZA, Vector2i(0, 18), 2, T_DIRT)       # Jungle
	_paint_road_line(PLAZA, Vector2i(W - 1, 40), 2, T_STONE) # Mining
	_paint_road_line(PLAZA, Vector2i(72, 0), 2, T_DIRT)       # Desert

	# Broad circular civic plaza.
	for y in range(PLAZA.y - 13, PLAZA.y + 14):
		for x in range(PLAZA.x - 18, PLAZA.x + 19):
			var delta := Vector2(float(x - PLAZA.x) / 1.35, float(y - PLAZA.y))
			if delta.length() <= 12.0:
				_path.set_cell(Vector2i(x, y), 0, T_STONE)

	# Bridges remove the canal's blocking water tiles.
	for bridge_y in [19, 40, 57, 67]:
		for y in range(bridge_y - 2, bridge_y + 3):
			for x in range(74, 85):
				var cell := Vector2i(x, y)
				_water.erase_cell(cell)
				_path.set_cell(cell, 0, T_PLANK)


func _paint_road_line(from: Vector2i, to: Vector2i, half_width: int, tile: Vector2i) -> void:
	var delta := to - from
	var steps := maxi(abs(delta.x), abs(delta.y))
	for i in range(steps + 1):
		var ratio := float(i) / float(maxi(steps, 1))
		var center := Vector2i(round(Vector2(from).lerp(Vector2(to), ratio)))
		for y in range(center.y - half_width, center.y + half_width + 1):
			for x in range(center.x - half_width, center.x + half_width + 1):
				if x >= 0 and x < W and y >= 0 and y < H:
					_path.set_cell(Vector2i(x, y), 0, tile)


func _paint_buildings() -> void:
	# Town Hall / cultural hall anchors the north side of the plaza.
	_paint_box(_props, 39, 7, 56, 17, BOX_WHITE)
	_paint_box(_above, 40, 4, 55, 7, BOX_BLUE)

	# Museum and archive in the northwest civic block.
	_paint_box(_props, 11, 15, 26, 25, BOX_STONE)
	_paint_box(_above, 11, 12, 26, 15, BOX_TERRACOTTA)

	# Restaurant row and public house west of the plaza.
	_paint_box(_props, 8, 38, 22, 48, BOX_WHITE)
	_paint_box(_above, 8, 35, 22, 38, BOX_BLUE)

	# Marketplace stalls south-east of the plaza.
	_paint_box(_props, 59, 48, 67, 52, BOX_BLUE)
	_paint_box(_props, 59, 55, 67, 59, BOX_TERRACOTTA)
	_paint_box(_props, 69, 48, 75, 52, BOX_WOOD)

	# Homes along the northeast road, before the canal.
	_paint_box(_props, 61, 10, 71, 19, BOX_WHITE)
	_paint_box(_above, 61, 7, 71, 10, BOX_TERRACOTTA)
	_paint_box(_props, 84, 22, 93, 31, BOX_WHITE)
	_paint_box(_above, 84, 19, 93, 22, BOX_BLUE)

	# Workshop near the Mining exit.
	_paint_box(_props, 84, 43, 93, 52, BOX_STONE)
	_paint_box(_above, 84, 40, 93, 43, BOX_TERRACOTTA)

	# Southern inn marks the road down to Harbor.
	_paint_box(_props, 38, 57, 53, 66, BOX_WHITE)
	_paint_box(_above, 38, 54, 53, 57, BOX_BLUE)


func _paint_fountain() -> void:
	for y in range(PLAZA.y - 6, PLAZA.y + 7):
		for x in range(PLAZA.x - 6, PLAZA.x + 7):
			var distance := Vector2(x - PLAZA.x, y - PLAZA.y).length()
			if distance < 6.2 and distance > 4.1:
				_path.set_cell(Vector2i(x, y), 0, T_STONE)
			elif distance <= 3.0:
				_props.set_cell(Vector2i(x, y), 0, Vector2i(3, 4))
	_props.set_cell(PLAZA, 0, Vector2i(3, 3))
	_props.set_cell(PLAZA + Vector2i(0, -1), 0, Vector2i(3, 3))


func _paint_gardens_and_details() -> void:
	# Formal public gardens around the plaza.
	for rect in [
		Rect2i(27, 22, 8, 7),
		Rect2i(61, 24, 8, 7),
		Rect2i(26, 45, 9, 7),
		Rect2i(61, 42, 8, 7),
	]:
		for y in range(rect.position.y, rect.end.y):
			for x in range(rect.position.x, rect.end.x):
				var cell := Vector2i(x, y)
				if x == rect.position.x or x == rect.end.x - 1 or y == rect.position.y or y == rect.end.y - 1:
					_decor.set_cell(cell, 0, T_FLOWER_BUSH)
				elif (x + y) % 2 == 0:
					_decor.set_cell(cell, 0, T_FLOWER)
				else:
					_decor.set_cell(cell, 0, T_FLOWER_WHITE)

	# Trees soften the outer districts while all five roads remain legible.
	for y in range(3, H - 2):
		for x in range(3, W - 2):
			if _is_reserved(x, y):
				continue
			if (x * 29 + y * 17) % 83 == 0:
				_props.set_cell(Vector2i(x, y), 0, T_TREE)
			elif (x * 19 + y * 11) % 61 == 0:
				_decor.set_cell(Vector2i(x, y), 0, T_BUSH)

	for p in [
		Vector2i(35, 28), Vector2i(61, 28),
		Vector2i(35, 44), Vector2i(61, 44),
		Vector2i(46, 20), Vector2i(50, 20),
		Vector2i(46, 52), Vector2i(50, 52),
	]:
		_props.set_cell(p, 0, T_LAMP)

	_props.set_cell(Vector2i(48, 48), 0, T_SIGN)
	_props.set_cell(Vector2i(72, 39), 0, T_BARREL)


func _is_reserved(x: int, y: int) -> bool:
	# Plaza and roads.
	if Vector2(float(x - PLAZA.x) / 1.35, float(y - PLAZA.y)).length() < 17.0:
		return true
	if x >= 44 and x <= 52:
		return true
	if y >= 36 and y <= 44:
		return true
	# Building blocks and canal.
	for rect in [
		Rect2i(37, 3, 21, 16), Rect2i(9, 11, 19, 16),
		Rect2i(6, 34, 18, 16), Rect2i(58, 6, 15, 15),
		Rect2i(82, 18, 13, 16), Rect2i(82, 39, 13, 15),
		Rect2i(36, 53, 19, 15), Rect2i(57, 46, 20, 15),
		Rect2i(75, 4, 10, 68),
	]:
		if rect.has_point(Vector2i(x, y)):
			return true
	return false


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
