# Progression

## Core driver

**Restoration projects** are the spine. Completing them should:

- Change the visible map
- Reopen businesses
- Return NPCs
- Unlock paths / regions
- Reveal story

## Layers

1. **Tools** — better gather / fish / mine access
2. **Resources & money** — fund projects
3. **Restorations** — district revival
4. **Social** — friendship / romance as areas recover
5. **World unlocks** — late regions and lore

## Soft vs hard gates

- Soft: better yields, faster chores, cosmetic town life
- Hard: vine walls, broken bridges, locked registry neighbors until conditions met

## Prototype hooks

- `RestorationCatalog` — project definitions
- `GameState.complete_restoration()` — persistence API
- Harbor / City restoration markers — visual hooks (unwired)

## Near-term goal

One Harbor restoration end-to-end: pay cost → mark complete → visible change → optional unlock.

## Anti-goals

- Invisible XP-only progression
- Expanding the farm while the town stays dead
- Unlocking the whole island before any district feels alive
