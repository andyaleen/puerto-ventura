# Backlog

Unordered work items not committed to the current sprint. Pull from here into `current_sprint.md`. Prefer small, shippable slices.

Related: [../roadmap.md](../roadmap.md), [milestones.md](milestones.md).

## World / maps

- [ ] Align Beach layout to hand sketch (lighthouse, road, dock, buildings)
- [ ] Beach north exit → farm/home region
- [ ] Beach east exit → town (clarify Harbor vs City)
- [ ] Add farm/home region scene + registry entry
- [ ] Update `region_registry.gd` neighbors to match intended graph
- [ ] Jungle tilemap (`build_jungle_map.gd` + hand polish)
- [ ] Hand-polish Harbor / City maps
- [ ] Locked-region stub pass (readable placeholders, correct exits)

## Restoration / progression

- [ ] Wire restoration markers → catalog → `GameState.complete_restoration()`
- [ ] First Harbor project end-to-end (cost → complete → visible change)
- [ ] Optional path/neighbor unlock on restoration complete
- [ ] First City restoration project
- [ ] Restoration UI prompt (cost, requirements, confirm)

## Gather / economy

- [ ] Expand resource categories beyond Beach shells/wood
- [ ] Spend money/resources on restorations
- [ ] Day loop usage beyond HUD display
- [ ] Basic tool upgrades / gather gates

## Signature loops (later)

- [ ] Fishing at Beach / Harbor docks
- [ ] Farming on farm/home
- [ ] Mining hooks for rocky / cave regions
- [ ] Dynamic region unlock conditions (not only static flags)

## People / story (later)

- [ ] NPC scenes + dialogue
- [ ] Friendship (and optional romance)
- [ ] Town ambient life after restorations
- [ ] Environmental storytelling props / notes

## Tech / polish

- [ ] Save / load
- [ ] Player walk cycle art
- [ ] Replace Kenney placeholders selectively
- [ ] Audio ambience + restoration stinger
- [ ] Decide combat stance (see `docs/design/combat.md`)

## Docs / process

- [ ] Update `AGENTS.md` to prefer `docs/design/` over legacy `game_design.md`
- [ ] Keep ADRs when architecture choices stick
