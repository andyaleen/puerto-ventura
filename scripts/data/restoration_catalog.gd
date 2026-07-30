class_name RestorationCatalog
extends RefCounted

## Stub catalog for restoration projects. Flesh out with costs and visual hooks later.

const PROJECTS := {
	"harbor_dock_repair": {
		"region": "harbor",
		"display_name": "Repair the Harbor Dock",
		"description": "Make the harbor docks safe enough for fishing boats to return.",
		"cost": {"wood": 10, "stone": 4},
	},
	"harbor_fountain": {
		"region": "harbor",
		"display_name": "Restore the Harbor Fountain",
		"description": "Clear debris and restart the fountain at the harbor plaza.",
		"cost": {"stone": 12, "fiber": 6},
	},
	"harbor_cafe": {
		"region": "harbor",
		"display_name": "Reopen the Seaside Café",
		"description": "Repair seating, restock supplies, and invite the first returning cooks.",
		"cost": {"wood": 20, "fiber": 8},
	},
	"city_marketplace": {
		"region": "city",
		"display_name": "Repair the City Marketplace",
		"description": "Rebuild stalls so traders can return to the city center.",
		"cost": {"wood": 30, "stone": 20, "fiber": 10},
	},
}


static func projects_for_region(region_id: String) -> Array:
	var result: Array = []
	for project_id in PROJECTS.keys():
		if PROJECTS[project_id]["region"] == region_id:
			result.append(project_id)
	return result
