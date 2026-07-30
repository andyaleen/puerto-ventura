class_name RegionRegistry
extends RefCounted

## Island region graph from the annotated overworld map.
## Orange connection points = neighbors. Red outlines = separate scenes.
## Only beach, harbor, city, and jungle start unlocked.

const REGIONS := {
	"beach": {
		"display_name": "Beach",
		"scene": "res://scenes/regions/beach/beach.tscn",
		"unlocked": true,
		"neighbors": ["harbor", "city", "jungle"],
	},
	"harbor": {
		"display_name": "Beach Harbor",
		"scene": "res://scenes/regions/harbor/harbor.tscn",
		"unlocked": true,
		"neighbors": ["beach", "city", "rocky_mining"],
	},
	"city": {
		"display_name": "Idyllic City Center",
		"scene": "res://scenes/regions/city/city.tscn",
		"unlocked": true,
		"neighbors": ["beach", "harbor", "jungle", "rocky_mining", "desert"],
	},
	"jungle": {
		"display_name": "Jungle",
		"scene": "res://scenes/regions/jungle/jungle.tscn",
		"unlocked": true,
		"neighbors": ["beach", "city", "volcano", "deep_jungle", "desert"],
	},
	"volcano": {
		"display_name": "Volcano",
		"scene": "res://scenes/regions/volcano/volcano.tscn",
		"unlocked": false,
		"neighbors": ["jungle", "deep_jungle"],
	},
	"deep_jungle": {
		"display_name": "Deeper Jungle",
		"scene": "res://scenes/regions/deep_jungle/deep_jungle.tscn",
		"unlocked": false,
		"neighbors": ["jungle", "volcano", "ancient_city"],
	},
	"ancient_city": {
		"display_name": "Secret Ancient High Tech Town",
		"scene": "res://scenes/regions/ancient_city/ancient_city.tscn",
		"unlocked": false,
		"neighbors": ["deep_jungle", "desert"],
	},
	"desert": {
		"display_name": "Desert",
		"scene": "res://scenes/regions/desert/desert.tscn",
		"unlocked": false,
		"neighbors": ["jungle", "city", "ancient_city", "rocky_mining", "mountain", "desert_cave"],
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
		"neighbors": ["harbor", "city", "desert", "cursed_area"],
	},
	"cursed_area": {
		"display_name": "Scary Cursed Part",
		"scene": "res://scenes/regions/cursed_area/cursed_area.tscn",
		"unlocked": false,
		"neighbors": ["rocky_mining", "mountain"],
	},
	"mountain": {
		"display_name": "Mountain",
		"scene": "res://scenes/regions/mountain/mountain.tscn",
		"unlocked": false,
		"neighbors": ["desert", "cursed_area", "mountain_summit"],
	},
	"mountain_summit": {
		"display_name": "Mountain Top",
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


static func get_neighbors(region_id: String) -> Array:
	return REGIONS[region_id].get("neighbors", [])


static func list_region_ids() -> Array:
	return REGIONS.keys()
