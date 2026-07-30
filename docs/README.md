# Puerto Ventura Docs

Design and engineering references for the Godot 4.7 island restoration life sim.

## Engineering

| File | Purpose |
|------|---------|
| [architecture.md](architecture.md) | Scene structure, autoloads, region loading, map/gameplay split |
| [roadmap.md](roadmap.md) | Build order and near-term milestones |
| [coding_rules.md](coding_rules.md) | Conventions for GDScript, scenes, and assets |
| [automation.md](automation.md) | Issue → Cursor → PR → director notify pipeline |

## Development

| File | Purpose |
|------|---------|
| [development/backlog.md](development/backlog.md) | Unordered work items |
| [development/milestones.md](development/milestones.md) | Coarse checkpoints / exit criteria |
| [development/current_sprint.md](development/current_sprint.md) | Active sprint goals |
| [development/architecture_decisions.md](development/architecture_decisions.md) | ADR log |

## Design

| File | Purpose |
|------|---------|
| [design/vision.md](design/vision.md) | Pitch, pillars, tone |
| [design/gameplay.md](design/gameplay.md) | Core loop and systems priorities |
| [design/player_movement.md](design/player_movement.md) | Milestone 1 walk / sprint / locks / animation contract |
| [design/world.md](design/world.md) | Modular regions and navigation |
| [design/characters.md](design/characters.md) | Player and NPCs |
| [design/locations.md](design/locations.md) | Region list and fantasies |
| [design/economy.md](design/economy.md) | Money, resources, sinks/sources |
| [design/crafting.md](design/crafting.md) | Tools and materials |
| [design/fishing.md](design/fishing.md) | Major fishing pillar |
| [design/farming.md](design/farming.md) | Supporting farm/home loop |
| [design/combat.md](design/combat.md) | Combat stance (TBD / light) |
| [design/progression.md](design/progression.md) | Restoration-driven progression |
| [design/ui.md](design/ui.md) | HUD and interface needs |
| [design/audio.md](design/audio.md) | Music and SFX intent |

## Legacy briefs

| File | Purpose |
|------|---------|
| [game_design.md](game_design.md) | Short summary (points into `design/`) |
| [PRD.md](PRD.md) | Original product requirements / design brief |

## Quick links

- Root project guide: [`../README.md`](../README.md)
- Region graph: `scripts/data/region_registry.gd`
- Shared tileset: `assets/tilesets/island_tileset.tres`
- Map bakers: `tools/build_*_map.gd`

## North star

Restoration over expansion. Every session should make the island feel more alive.
