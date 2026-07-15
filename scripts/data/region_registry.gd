class_name RegionRegistry
extends RefCounted

## Single source of truth for modular region scenes and metadata.
## Add new maps here when expanding the island.

const REGIONS := {
	"beach": {
		"display_name": "Beach",
		"scene": "res://scenes/regions/beach/beach.tscn",
		"unlocked": true,
		"neighbors": ["beach_town"],
	},
	"beach_town": {
		"display_name": "Beach Town",
		"scene": "res://scenes/regions/beach_town/beach_town.tscn",
		"unlocked": true,
		"neighbors": ["beach", "jungle", "city_center"],
	},
	"jungle": {
		"display_name": "Jungle",
		"scene": "res://scenes/regions/jungle/jungle.tscn",
		"unlocked": true,
		"neighbors": ["beach_town", "deep_jungle", "mountain"],
	},
	"deep_jungle": {
		"display_name": "Deep Jungle",
		"scene": "res://scenes/regions/deep_jungle/deep_jungle.tscn",
		"unlocked": false,
		"neighbors": ["jungle"],
	},
	"desert": {
		"display_name": "Desert",
		"scene": "res://scenes/regions/desert/desert.tscn",
		"unlocked": false,
		"neighbors": ["beach_town", "desert_cave", "rocky_mining"],
	},
	"desert_cave": {
		"display_name": "Desert Cave",
		"scene": "res://scenes/regions/desert_cave/desert_cave.tscn",
		"unlocked": false,
		"neighbors": ["desert"],
	},
	"rocky_mining": {
		"display_name": "Rocky Mining Area",
		"scene": "res://scenes/regions/rocky_mining/rocky_mining.tscn",
		"unlocked": false,
		"neighbors": ["desert"],
	},
	"city_center": {
		"display_name": "Idyllic City Center",
		"scene": "res://scenes/regions/city_center/city_center.tscn",
		"unlocked": false,
		"neighbors": ["beach_town", "mountain"],
	},
	"mountain": {
		"display_name": "Mountain",
		"scene": "res://scenes/regions/mountain/mountain.tscn",
		"unlocked": false,
		"neighbors": ["jungle", "city_center", "mountain_summit"],
	},
	"mountain_summit": {
		"display_name": "Mountain Summit",
		"scene": "res://scenes/regions/mountain_summit/mountain_summit.tscn",
		"unlocked": false,
		"neighbors": ["mountain"],
	},
}


static func has_region(region_id: String) -> bool:
	return REGIONS.has(region_id)


static func get_scene_path(region_id: String) -> String:
	return String(REGIONS[region_id]["scene"])


static func get_display_name(region_id: String) -> String:
	return String(REGIONS[region_id]["display_name"])


static func is_unlocked(region_id: String) -> bool:
	return bool(REGIONS[region_id].get("unlocked", false))


static func list_region_ids() -> Array:
	return REGIONS.keys()
