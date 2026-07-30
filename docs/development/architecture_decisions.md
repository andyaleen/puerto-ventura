# Architecture Decisions

Lightweight ADR log. Record choices that agents and humans should not silently reverse.

Format per entry:

- **Status:** Proposed | Accepted | Superseded
- **Context → Decision → Consequences**

Do not redesign architecture in code unless requested; propose an ADR here first ([AGENTS.md](../../AGENTS.md)).

---

## ADR-001: Modular region scenes

- **Status:** Accepted
- **Context:** Need a large island without loading everything at once.
- **Decision:** One Godot scene per region; `RegionManager` fade-loads neighbors from `region_registry.gd`.
- **Consequences:** Independent editing and better performance; no seamless streaming; exits/spawns must stay consistent across scenes.

## ADR-002: Split map visuals from gameplay

- **Status:** Accepted
- **Context:** Tile painting and gameplay objects tangle if mixed.
- **Decision:** `<id>_map.tscn` holds TileMapLayers; `<id>.tscn` instances the map and owns exits, spawns, pickups, restoration markers.
- **Consequences:** Clear ownership; bakers can regenerate maps carefully; gameplay must not be painted into map scenes.

## ADR-003: Shared Kenney-based tileset pipeline

- **Status:** Accepted (prototype)
- **Context:** Need fast placeholder art across regions.
- **Decision:** Bake `island_tileset.tres` from Kenney sheets via `tools/build_tileset.gd`; optional `build_<region>_map.gd` then hand polish.
- **Consequences:** Consistent look early; custom art later may require tileset migration; avoid wiping hand polish when rebaking.

## ADR-004: GameState + catalog stubs for restoration

- **Status:** Accepted (incomplete wiring)
- **Context:** Restoration is the progression spine.
- **Decision:** Define projects in `restoration_catalog.gd`; persist via `GameState`; place markers in region gameplay scenes.
- **Consequences:** Clear extension point; until wired, markers are decorative only.

## ADR-005: Farm/home as region separate from Beach

- **Status:** Proposed
- **Context:** Beach hand map shows north exit to farm/home; Beach should stay shoreline-focused.
- **Decision (proposed):** Add a dedicated farm/home region id and Beach north `RegionExit`.
- **Consequences:** Extra scene + registry work; clearer farming scope; must pick id (`farm`, `home`, etc.) and neighbors.

## ADR-006: Combat scope

- **Status:** Proposed
- **Context:** Cozy restoration fantasy vs late hazardous regions.
- **Decision:** TBD — prefer none or very light hazards; document in `docs/design/combat.md` before implementing.
- **Consequences:** Avoid building battle systems until decided.
