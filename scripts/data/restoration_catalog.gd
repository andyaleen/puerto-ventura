class_name RestorationCatalog
extends RefCounted

## Stub catalog for restoration projects. Flesh out with costs and visual hooks later.

const PROJECTS := {
	"beach_dock_repair": {
		"region": "beach",
		"display_name": "Repair the Small Dock",
		"description": "Make the beach dock safe enough for small fishing boats.",
		"cost": {"wood": 10, "stone": 4},
	},
	"town_fountain": {
		"region": "beach_town",
		"display_name": "Restore the Town Fountain",
		"description": "Clear debris and restart the fountain at the town square.",
		"cost": {"stone": 12, "fiber": 6},
	},
	"town_cafe": {
		"region": "beach_town",
		"display_name": "Reopen the Seaside Café",
		"description": "Repair seating, restock supplies, and invite the first returning cooks.",
		"cost": {"wood": 20, "fiber": 8},
	},
	"harbor_gates": {
		"region": "beach_town",
		"display_name": "Repair the Harbor Gates",
		"description": "Stabilize the damaged harbor so boats can return.",
		"cost": {"wood": 30, "stone": 20, "fiber": 10},
	},
}


static func projects_for_region(region_id: String) -> Array:
	var result: Array = []
	for project_id in PROJECTS.keys():
		if PROJECTS[project_id]["region"] == region_id:
			result.append(project_id)
	return result
