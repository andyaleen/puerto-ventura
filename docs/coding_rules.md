# Coding Rules

Conventions for Puerto Ventura GDScript and scenes.

## General

- Prefer small, focused scripts over god-objects.
- Match existing naming and folder layout before inventing new patterns.
- Do not commit secrets, local Godot user data, or generated junk.
- Keep gameplay logic out of pure visual map scenes.

## Folder layout

```
assets/          tilesheets, tilesets, sprites, licenses
docs/            design + engineering docs
scenes/player/   player controller / camera
scenes/regions/  one folder per region
scenes/systems/  shared gameplay nodes (exits, HUD, pickups, fade)
scripts/autoload/
scripts/data/
scripts/regions/
tools/           headless bake scripts
```

## Regions

- Region id = folder name = registry key (snake_case): `beach`, `harbor`, `city`.
- Gameplay scene: `scenes/regions/<id>/<id>.tscn`
- Visual map scene: `scenes/regions/<id>/<id>_map.tscn` (when tilemapped)
- Register every playable region in `scripts/data/region_registry.gd`.
- Neighbor lists must match placed `RegionExit` targets.
- Extend shared region behavior via `region_base.gd` when possible.

## Maps and art

- Paint tiles only in `*_map.tscn` layers.
- Keep exits, spawns, pickups, and restoration markers in `<id>.tscn`.
- Prefer editing maps by hand in Godot after a baker pass.
- If regenerating with bakers, avoid wiping hand-polish without a backup.
- Placeholder art is Kenney CC0; keep licenses under `assets/licenses/`.

## GDScript style

- Use typed variables and return types when practical.
- Prefer `class_name` / `extends` patterns already used in the repo.
- Autoload access: `GameState`, `RegionManager` (no duplicate global state).
- Stub unfinished systems clearly (short comments), then wire them before adding parallel stubs.
- Avoid drive-by refactors unrelated to the current change.

## Interactions

- Interact key: `E` (keep consistent unless input map is intentionally redesigned).
- Travel: walk into `RegionExit` areas; respect unlock flags.
- Collectibles: update `GameState` through existing APIs.

## Restoration

- Define projects in `restoration_catalog.gd`.
- Persist completion through `GameState`.
- Visible world change is required for a “done” restoration (tile swap, prop, unlock, etc.).
- Markers in Harbor / City are the preferred hooks for first implementations.

## Tools / headless

Bake scripts live in `tools/` and should be runnable as:

```bash
godot --headless --path . --script res://tools/build_tileset.gd
godot --headless --path . --script res://tools/build_<region>_map.gd
```

## Docs

- Update `docs/roadmap.md` when phase status meaningfully changes.
- Keep `docs/architecture.md` in sync with new autoloads or region patterns.
- Prefer editing design intent in `docs/game_design.md`; keep `PRD.md` as the longer source brief.
