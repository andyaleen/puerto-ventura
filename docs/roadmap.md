# Roadmap

Order of operations for turning the movement prototype into a restoration life sim.

Kenney / placeholder art is fine until the core loop feels good. Custom graphics come later.

## Phase 0 — Done (prototype shell)

- [x] Modular region loading + fade transitions
- [x] Region registry / neighbor graph
- [x] Player movement + basic HUD
- [x] Beach / Harbor / City tilemap pipeline
- [x] Beach pickups feeding GameState
- [x] Restoration catalog + markers (unwired)

## Phase 1 — Finish the starting world

Goal: four starting regions feel like real places you can walk through.

1. Align Beach layout to the hand map (lighthouse, road, dock, buildings, exits)
2. Add a **farm / home** region if north-from-Beach should be separate from Harbor/City
3. Update `region_registry.gd` exits to match the intended graph
4. Build / polish Jungle tilemap (last unlocked stub)
5. Hand-polish Beach / Harbor / City maps in the editor

## Phase 2 — One real progression loop (restoration)

Goal: gather → spend → restore → see the world change.

1. Wire restoration markers to `RestorationCatalog` + `GameState.complete_restoration()`
2. Implement one Harbor project end-to-end (cost → complete → visible tile/prop change)
3. Optionally unlock a path or neighbor when a restoration finishes
4. Repeat for a City project

## Phase 3 — Gather / earn that feeds restoration

Goal: beach and nearby areas give reasons to explore between restorations.

1. Expand resource pickups and categories
2. Simple economy (spend money/resources on restorations)
3. Day / money usage beyond HUD display
4. Basic tool upgrades if needed for gather gates

## Phase 4 — Signature loops

Per design pillars, after restoration actually works:

1. **Fishing** (major pillar) — Beach / Harbor docks
2. Farming on the farm/home area (present, but not dominant)
3. Mining hooks for rocky / cave regions later
4. Region unlock conditions driven by restoration / story, not hardcoded forever

## Phase 5 — People and story

1. NPCs return as districts restore
2. Dialogue / friendship
3. Town evolution (shops reopen, festivals, ambient life)
4. Environmental storytelling toward late-game mystery regions

## Phase 6 — Art and late game

1. Replace Kenney placeholders with custom tiles / characters as needed
2. Player walk cycles and building art
3. Locked regions: volcano, deep jungle, desert, caves, cursed area, mountain, ancient city
4. Save / load polish, content pass, balancing

## Near-term next actions

1. Beach map pass from the hand sketch
2. Decide farm/home vs Harbor naming in the registry
3. Wire first Harbor restoration project
