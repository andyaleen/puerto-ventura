# Current Sprint

**Sprint focus:** Starting-world clarity (Beach + graph) toward M1.

**Dates:** TBD  
**Milestone target:** [M1 — Starting world](milestones.md)

## Goals this sprint

1. Capture Beach layout from the hand sketch (structure first, Kenney art OK)
2. Decide farm/home region vs reusing an existing unlocked neighbor
3. Align Beach exits + `region_registry` with north→home, east→town

## In progress

- [ ] Beach map pass (lighthouse, road, dock, buildings, water edges)
- [ ] Farm/home naming + registry decision
- [ ] Exit/spawn wiring for Beach north & east

## Up next (if sprint capacity remains)

- [ ] Jungle tilemap baker + basic layout
- [ ] Spike: wire one Harbor restoration marker to GameState

## Done this sprint

- [x] Design docs under `docs/design/`
- [x] Development docs folder created

## Blocked / needs decision

| Item | Question |
|------|----------|
| East of Beach | Is “town” Harbor, City, or a new region? |
| North of Beach | New `farm` / `home` region id? |
| Combat | Confirm none / light before deep-jungle content |

## Notes

Kenney placeholders remain acceptable. Prefer map + graph correctness over new systems this sprint.
