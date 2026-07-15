# Puerto Ventura

A cozy 2D top-down island restoration life sim made in **Godot 4**.

You inherit a beach cottage on a nearly abandoned paradise. Explore modular regions, gather resources, restore districts, reopen businesses, and uncover why the island fell silent.

## Open in Godot

1. Install [Godot 4.3+](https://godotengine.org/download) (Standard / Forward+ is fine).
2. In Godot: **Import** → select `C:\Users\andy\Code projects\PuertoVentura\project.godot`.
3. Press **F5** (or Play) to start on the Beach.

## Controls

| Action | Keys |
|--------|------|
| Move | WASD / Arrow keys |
| Interact | E |

## Current prototype

- Modular region maps that load one at a time
- Fade-to-black transitions between regions
- Playable **Beach** ↔ **Beach Town** loop
- Stub scenes for every Version 1 region (ready to expand)
- Lightweight GameState + RegionManager autoloads

## World architecture

Each region is its own scene under `scenes/regions/`. Players walk into an exit trigger:

1. Screen fades to black
2. Target region loads
3. Player appears at the destination spawn
4. Screen fades back in

Add a new region later by:

1. Creating `scenes/regions/<id>/<id>.tscn` extending the region base
2. Registering it in `scripts/data/region_registry.gd`
3. Placing `RegionExit` nodes that point to neighboring regions

## Project layout

```
docs/                 Design docs (PRD)
scenes/player/        Player controller
scenes/regions/       One scene per world region
scenes/systems/       Exits, fade overlay, HUD helpers
scripts/autoload/     GameState, RegionManager
scripts/data/         Region registry and restoration stubs
```

## Design north star

Restoration over expansion. Every session should make the island feel more alive.
