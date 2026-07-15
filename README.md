# Puerto Ventura

A cozy 2D top-down island restoration life sim made in **Godot 4.7**.

You inherit a beach cottage on a nearly abandoned paradise. Explore modular regions, gather resources, restore districts, reopen businesses, and uncover why the island fell silent.

## Open in Godot

1. Open Godot 4.7+ → **Import** → `project.godot`
2. Press **F5** to start on the Beach
3. Switch the editor to the **2D** tab when editing maps (not 3D)

## Controls

| Action | Keys |
|--------|------|
| Move | WASD / Arrow keys |
| Interact | E |

## Current prototype

- Modular region maps that load one at a time
- Fade-to-black transitions between regions
- Playable **Beach** (Kenney tilemap) ↔ Beach Town ↔ Jungle
- Shared `island_tileset.tres` built from Kenney CC0 sheets
- Lightweight GameState + RegionManager autoloads

## How maps and graphics work

Beach is the template for every future region:

1. **Art lives in** `assets/tilesheets/` (Kenney CC0, 16×16 tiles, 1px separation)
2. **Shared TileSet** is baked by `tools/build_tileset.gd` → `assets/tilesets/island_tileset.tres`
3. **Map layout** is baked by `tools/build_beach_map.gd` → `scenes/regions/beach/beach_map.tscn`
4. **Gameplay scene** `beach.tscn` instances that map and adds exits, spawns, pickups

### Regenerate the Beach map (optional)

From a terminal with Godot on PATH, or using your Godot console exe:

```bash
godot --headless --path . --script res://tools/build_tileset.gd
godot --headless --path . --script res://tools/build_beach_map.gd
```

### Edit maps by hand in Godot (recommended for polish)

1. Open `scenes/regions/beach/beach_map.tscn`
2. Select the `Ground` or `Props` TileMapLayer
3. Paint tiles from the TileSet dock
4. Keep exits/spawns in `beach.tscn` (not in the generated map)

Rule of thumb: **paint visuals in the map scene, keep gameplay in the region scene.**

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
assets/tilesheets/    Kenney spritesheets
assets/tilesets/      Shared TileSet resource
assets/sprites/       Character sprites
docs/                 Design docs (PRD)
scenes/player/        Player controller
scenes/regions/       One scene per world region
scenes/systems/       Exits, fade overlay, HUD, pickups
scripts/autoload/     GameState, RegionManager
scripts/data/         Region registry and restoration stubs
tools/                Headless bake scripts
```

## Art credits

Placeholder art is **CC0** from [Kenney.nl](https://kenney.nl):

- Roguelike/RPG pack
- Roguelike characters
- RPG Urban pack

Licenses are copied under `assets/licenses/`.

## Design north star

Restoration over expansion. Every session should make the island feel more alive.
