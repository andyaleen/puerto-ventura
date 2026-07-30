# Architecture

## Overview

Puerto Ventura is a Godot 4.7 2D top-down game. The island is split into **modular region scenes**. Only one region is loaded at a time. Travel uses fade transitions between neighbor regions registered in a graph.

## Autoloads

| Autoload | Role |
|----------|------|
| `GameState` | Persistent progress: money, day, resources, completed restorations |
| `RegionManager` | Loads target region scenes and places the player at the correct spawn |

## Region model

Each region lives under `scenes/regions/<id>/`:

```
<id>.tscn          Gameplay: player spawn, exits, pickups, restoration markers
<id>_map.tscn      Visuals: TileMapLayers painted from the shared tileset
```

**Rule:** paint visuals in the map scene; keep gameplay in the region scene.

### Region registration

`scripts/data/region_registry.gd` defines:

- display name
- scene path
- unlocked flag
- neighbor list

Exits use `RegionExit` nodes. If the target region is locked, travel is blocked with feedback.

### Transition flow

1. Player enters a `RegionExit` area
2. Screen fades to black
3. Target region scene loads
4. Player appears at the destination spawn
5. Screen fades back in

## Map / art pipeline

1. Source tilesheets in `assets/tilesheets/` (Kenney CC0, 16×16, 1px separation)
2. `tools/build_tileset.gd` bakes `assets/tilesets/island_tileset.tres`
3. `tools/build_<region>_map.gd` generates a starting layout into `<region>_map.tscn`
4. Hand-polish layers in the Godot editor:
   - `GroundLayer`
   - `PathLayer`
   - `WaterLayer`
   - `PropsLayer`
   - `DecorLayer`
   - `AbovePlayerLayer`

## Systems folder

Shared gameplay pieces under `scenes/systems/`:

- fade overlay
- region HUD
- pickups
- region exits

Shared region behavior lives in `scripts/regions/region_base.gd`.

## Data stubs

| Script | Purpose |
|--------|---------|
| `restoration_catalog.gd` | Restoration project definitions (costs / hooks to flesh out) |
| `region_registry.gd` | Island graph and unlock flags |

## Player movement

Milestone 1 walk / sprint / movement-lock / animation-contract intent lives in [`design/player_movement.md`](design/player_movement.md). Lock API: [ADR-007](development/architecture_decisions.md#adr-007-player-movement-lock-api) (**Accepted**). The player owns a named movement-lock set; locomotion runs only when that set is empty. `RegionManager` acquires/releases `&"region_transition"` during travel. `RegionManager.is_busy()` remains for transition orchestration, not as the player movement gate.

## Current playable shell

Starting unlocked regions: Beach, Harbor, City, Jungle.

Beach / Harbor / City have tilemaps. Jungle and locked late-game regions are still stubs or unfinished maps.

Beach layout intent (hand sketch): north exit to farm/home, east exit to town, lighthouse west, dock southeast, central road, scattered buildings.
