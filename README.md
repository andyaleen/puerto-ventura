# Puerto Ventura

A 2D top-down island restoration life sim made in **Godot 4.7**.

Restore a forgotten tropical island one district at a time. Rebuild businesses, uncover buried ruins, revive the local economy, and unravel ancient mysteries.

## Open in Godot

1. Open Godot 4.7+ → **Import** → `project.godot`
2. Press **F5** to start the full game on the Beach
3. Press **F6** to play the scene currently open in the editor (e.g. City)
4. Switch the editor to the **2D** tab when editing maps (not 3D)

## Controls

| Action | Keys |
|--------|------|
| Move | WASD / Arrow keys |
| Interact | E |

## Current prototype

- Modular region maps that load one at a time
- Fade-to-black transitions between regions
- Annotated island region graph with fade loads between zones
- Starting unlocked: **Beach**, **Harbor**, **City**, **Jungle**
- Shared `island_tileset.tres` built from Kenney CC0 sheets
- Lightweight GameState + RegionManager autoloads

## How maps and graphics work

Beach, Harbor, and City use the same map template:

1. **Art lives in** `assets/tilesheets/` (Kenney CC0, 16×16 tiles, 1px separation)
2. **Shared TileSet** is baked by `tools/build_tileset.gd` → `assets/tilesets/island_tileset.tres`
3. **Map layouts** are baked by `tools/build_<region>_map.gd`
4. **Gameplay scenes** instance their map and add exits, spawns, pickups, and restoration markers

### Regenerate generated maps (optional)

From a terminal with Godot on PATH, or using your Godot console exe:

```bash
godot --headless --path . --script res://tools/build_tileset.gd
godot --headless --path . --script res://tools/build_beach_map.gd
godot --headless --path . --script res://tools/build_harbor_map.gd
godot --headless --path . --script res://tools/build_city_map.gd
```

### Edit maps by hand in Godot (recommended for polish)

1. Open `scenes/regions/<region>/<region>_map.tscn`
2. Select `GroundLayer`, `PathLayer`, `WaterLayer`, `PropsLayer`, `DecorLayer`, or `AbovePlayerLayer`
3. Paint tiles from the TileSet dock
4. Keep exits/spawns in `<region>.tscn` (not in the generated map)

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
