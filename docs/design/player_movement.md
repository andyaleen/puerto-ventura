# Player Movement — Milestone 1 Specification

Authoritative Milestone 1 (vertical slice) behavior for player locomotion. High-level bullets also appear under Player Movement in [`../development/backlog.md`](../development/backlog.md); **this document wins** where they disagree for M1 scope.

**Implementation status:** Movement-lock API and `region_transition` integration are implemented on the player / `RegionManager` (ADR-007 Accepted). Sprint input action (`sprint`) and hold-to-sprint speed (`move_speed * sprint_multiplier`, default 1.6) are implemented on the player. Movement-state enum exposure and the animation contract remain follow-up work.

**Compatibility targets:** `CharacterBody2D` player, `RegionManager`, modular region scenes, existing move/interact input actions, and future dialogue, fishing, tools, mounts, and combat systems.

---

## Current prototype (baseline)

Already in `scenes/player/player.gd` / `player.tscn`:

| Behavior | Current |
|----------|---------|
| Directions | Eight-way via `Input.get_vector("move_left", "move_right", "move_up", "move_down")` |
| Speed | `@export var move_speed: float = 110.0` on the player |
| Sprint | Hold `sprint` (Shift / LB) with movement input → `move_speed * sprint_multiplier` (default 1.6) |
| Diagonal | Input vector normalized before applying speed |
| Acceleration | Immediate full speed / stop (no ramp) |
| Collision | `CharacterBody2D`; `collision_layer = 2` (player), `collision_mask = 1` (world) |
| Region travel lock | `RegionManager` acquires `&"region_transition"` on the player via the movement-lock API |
| Facing | Horizontal `flip_h` only when `input_vector.x != 0` |
| Feedback | Placeholder sprite bob while moving (faster cadence while sprinting, scaled by `sprint_multiplier`) |

Baseline locomotion above is current; remaining gaps are the movement-state enum and animation-contract getters.

---

## Walking

### Directions

- Support **eight directions**: cardinal and diagonal.
- Read from existing actions: `move_left`, `move_right`, `move_up`, `move_down` (keyboard: WASD + arrows; see `project.godot`).
- Dead zone follows Godot input map defaults (`0.5` on those actions).

### Base speed

- Base walk speed is configured on the **player controller** as an exported float (`move_speed`).
- Default for M1 remains **110** world units/sec unless playtesting adjusts the export (no magic constants duplicated in other systems).
- Other systems must not hardcode walk speed; they may query the player if needed.

### Diagonal normalization

- Always normalize non-zero movement input before multiplying by speed so diagonals are not faster than cardinals.
- Match current `input_vector.normalized() * speed` pattern.

### Acceleration / deceleration

- **Immediate** full walk (or sprint) speed when input is present; **immediate** stop when input clears or movement is locked.
- No acceleration curves, friction ramps, or momentum for M1.
- Rationale: matches the existing prototype and typical cozy top-down feel; keeps animation and lock timing simple.

### When walking is allowed

| Context | Walk allowed? |
|---------|---------------|
| Free exploration | Yes |
| Menus / inventory UI open | No |
| Dialogue active | No |
| Player in `INTERACTING` (short interaction hold) | No |
| Cutscenes / scripted camera moments | No |
| Region transition (`region_transition` lock) | No |
| Fishing minigame active | No |
| Tool-use animation / active tool swing (post-M1 tools) | No |

---

## Sprinting

### Input

- Add a dedicated input action: **`sprint`**.
- Default bindings (implementation ticket):
  - Keyboard: **Shift** (left and/or right)
  - Gamepad: left stick click or a shoulder button (prefer **LB / L1**); exact pad binding may be tuned later
- Sprint is **hold-to-sprint**, not toggle, for M1.
- Remapping UI is out of scope for this spec’s implementation phase; action exists in the input map only.

### Speed

- Sprint speed = **`move_speed * sprint_multiplier`**.
- Default **`sprint_multiplier = 1.6`**, exported next to `move_speed` on the player controller.
- Still normalized on diagonals.

### Stamina

- Sprinting **does not consume stamina** (or any energy meter) in Milestone 1 or in the current design backlog.
- No sprint cooldown.

### Restrictions

| Context | Sprint allowed? |
|---------|-----------------|
| Outdoors | Yes |
| Indoors / interior-like areas (when they exist) | Yes |
| Carrying items (when carry exists) | Yes for M1 unless a later carry spec overrides |
| Free exploration, no locks | Yes (with movement input) |
| Dialogue, menus, cutscenes | No |
| Region transitions | No |
| Fishing minigame | No |
| Tool-use / interact hold | No |
| Mounted (post-M1) | N/A — mount system owns locomotion |

If movement is locked for any reason, sprint input is ignored (player stays stopped or in the locked pose).

### Animation and facing

- Sprint uses the same facing rules as walk (see [Animation contract](#animation-contract)).
- When sprint anims exist: play sprint (or sped-up walk) while sprinting; until then, placeholder bob may run slightly faster while sprinting.
- Releasing sprint while still moving transitions to walk without facing reset.
- Releasing movement while holding sprint → `IDLE` (do not “slide”).

---

## Movement states

### Minimum states (M1)

| State | Meaning |
|-------|---------|
| `IDLE` | Not locked; no movement input (or zero velocity intent) |
| `WALKING` | Not locked; movement input without sprint |
| `SPRINTING` | Not locked; movement input and sprint held |
| `INTERACTING` | Short player-driven interaction that freezes locomotion (e.g. pickup confirm, interact wind-up) |
| `LOCKED` | One or more external movement locks are active |

`INTERACTING` is a **player-local** busy state. Long-form systems (dialogue UI, fishing minigame, menus, cutscenes, region travel) should use **`LOCKED`** via the [movement-lock API](#movement-lock-api) rather than overloading `INTERACTING`.

### Transition rules

```
LOCKED has priority over all locomotion and INTERACTING.

When lock count > 0:
  → LOCKED (clear velocity; ignore move/sprint)

When lock count == 0:
  INTERACTING (if interact hold active)
    → ignore move/sprint until interact completes
  else if movement input == 0:
    → IDLE
  else if sprint held:
    → SPRINTING
  else:
    → WALKING
```

- Entering `LOCKED` cancels in-progress `INTERACTING` locomotion effects (interaction systems should cancel or finish cleanly on their own).
- Leaving `LOCKED` returns to `IDLE` / `WALKING` / `SPRINTING` based on **current** input (no buffered sprint from during the lock unless still held).
- `IDLE` → `WALKING` / `SPRINTING` on movement input; reverse on release.
- `WALKING` ↔ `SPRINTING` solely from sprint action while moving.

### Formal state machine vs explicit checks

- Milestone 1 **does not require** a general-purpose state-machine framework or plugin.
- Prefer:
  1. A small `enum MovementState` for animation / debug
  2. Explicit lock set (see below)
  3. Derived locomotion state each physics frame from locks + input
- A heavier FSM may be proposed later if mounts/combat/tools make transitions painful; document that in an ADR before refactoring.

---

## Input and movement locks

### Problem

Previously only `RegionManager.is_busy()` gated movement. Dialogue, menus, fishing, cutscenes, and tools each need freezes. Independent booleans (`can_move = true` from one system) would incorrectly clear another system’s freeze.

### Coordination rule

- **No system may “enable movement” globally.**
- Systems only **acquire** and **release** named locks.
- The player moves iff the active lock set is **empty** (and not in local `INTERACTING`).

### Systems that may lock movement (M1 + near-term)

| Source id (suggested) | When acquired | When released |
|-----------------------|---------------|---------------|
| `region_transition` | Travel starts / fade-out | Transition finished (or failed rollback) |
| `dialogue` | Dialogue UI opens | Dialogue UI closes |
| `menu` | Modal menu / inventory / pause that should freeze the world | Menu closes |
| `cutscene` | Scripted cutscene starts | Cutscene ends |
| `fishing` | Fishing minigame starts | Minigame ends (catch, cancel, or fail) |
| `tool_use` | Tool swing / channel starts (mostly post-M1) | Animation / channel ends |
| `scripted_event` | Blocking story/scripted beat | Beat completes |

Region transitions use **`RegionManager` acquiring `region_transition`** on the player. The player’s lock set is the source of truth for locomotion; `is_busy()` remains for transition orchestration and other non-movement consumers.

### Movement-lock API

Required for M1 implementation (see [ADR-007](../development/architecture_decisions.md#adr-007-player-movement-lock-api)):

```
request_movement_lock(source: StringName) -> void
release_movement_lock(source: StringName) -> void
is_movement_locked() -> bool
get_movement_lock_sources() -> Array[StringName]  # debug / assertions
```

Rules:

- Duplicate `request` with the same `source` is idempotent (still one entry).
- `release` of an unknown source is a no-op (optionally `push_warning` in debug).
- Locks are **not** reference-counted per source unless a single source truly nests; prefer one acquire/release pair per logical ownership span.
- On region scene change, locks tied to the old scene must not leak: transition flow clears or never leaves orphan sources; new player instance starts with an empty set.
- Autoloads that survive scene changes (`RegionManager`, future Dialogue) must release on failure paths.

Optional later: a tiny `MovementLock` helper/`class_name` used by systems; **not** a separate autoload unless multiple non-player bodies need the same API.

---

## Collision expectations

Physics layers (existing): `world` (1), `player` (2), `exits` (3), `interactables` (4).

| Collider | M1 expectation |
|----------|----------------|
| Terrain / water blockers / cliffs | Solid via world layer; player `move_and_slide()` against mask bit 1 |
| Buildings / static props with collision | Same world layer static shapes in region gameplay or map collision |
| Static obstacles (fences, rocks) | World layer |
| Region exits | `Area2D` on exits layer — **trigger only**, not solid pushback |
| Interactable objects (pickups, markers) | Prefer `Area2D` on interactables — overlap for prompts, not solid blocking unless a specific prop needs a world collider |
| NPCs | **Out of this ticket.** Introduce with the Basic NPC system: decide blocking collision vs overlap-only then. Until NPCs exist, do not add player↔NPC collision layers “just in case.” |

Player remains a single `CharacterBody2D` with a small foot collider (current ~10×8 shape). Do not switch to `RigidBody2D` for M1.

---

## Animation contract

The player controller must expose read-only movement data for a future animation controller (sprite frames / `AnimationPlayer`). Placeholder art and bob may remain until art tickets.

### Required signals or getters

| Data | Type / notes |
|------|----------------|
| `movement_state` | `IDLE` \| `WALKING` \| `SPRINTING` \| `INTERACTING` \| `LOCKED` |
| `facing_direction` | Last **non-zero** facing as `Vector2` (at least horizontal; prefer 8-way unit vector when vertical-only input is used) |
| `movement_direction` | Current intended move direction (`Vector2.ZERO` when idle/locked) |
| `is_walking` | `movement_state == WALKING` |
| `is_sprinting` | `movement_state == SPRINTING` |
| `is_movement_locked` | Lock set non-empty **or** state is `LOCKED` |

Facing rules for M1:

- Update `facing_direction` whenever movement input is non-zero.
- Horizontal component may drive `flip_h` until 8-directional frames exist.
- Pure vertical input keeps last horizontal flip but should still store up/down in `facing_direction` for future anims.
- Locks do not reset facing.

Out of scope here: final walk/sprint/idle frame sets, tool/fish/combat anims (those systems will extend the contract later).

---

## Architecture

### Player controller owns

- Reading move + sprint input (when not locked / not interacting)
- Applying velocity via `CharacterBody2D.move_and_slide()`
- Maintaining facing + movement state enum
- Implementing the movement-lock set and public acquire/release API
- Exposing the animation contract
- Registering with `RegionManager` as today
- Local `INTERACTING` timing for brief player-side interacts

### Remain outside the player controller

| Concern | Owner |
|---------|--------|
| Region load / fade / spawn placement | `RegionManager` + region scenes |
| Dialogue presentation | Future dialogue system |
| Modal menus / inventory UI | Future UI system |
| Fishing minigame rules | Fishing system |
| Tool definitions / hit detection | Tools system (later) |
| NPC AI and NPC collision policy | Basic NPC system |
| Camera limits / cutscene pans | Camera / cutscene (camera changes out of this ticket’s implementation) |
| Game progress / day / money | `GameState` |

External systems **request locks** and drive their own UI/minigames; they do not set `velocity` on the player directly except through documented APIs (locks + future forced-move helpers if ever needed).

### Reusable lock API

- **Yes — required** for M1 implementation: lock API on the player (see ADR-007).
- Prefer methods on the player (group `"player"` / `RegionManager.get_player()`) over a new autoload unless a second consumer appears.

### ADR requirement

Significant architectural addition (coordinated movement locks) is recorded as **ADR-007** in [`../development/architecture_decisions.md`](../development/architecture_decisions.md). No silent redesign of region loading or `CharacterBody2D` usage.

---

## Milestone 1 vs later systems

### In M1 movement scope

- Walk, sprint (no stamina), states above, lock API, world collision, animation data hooks
- Integration points for dialogue, menus, fishing, and region travel locks
- Compatible with Basic NPCs once that ticket defines collision

### Explicitly later (do not implement under “M1 movement”)

| System | Notes |
|--------|-------|
| Tool-use locomotion | Lock source reserved; behavior in tools tickets |
| Mounts | Separate locomotion mode (backlog); not a movement state in M1 |
| Combat movement / dodge | Combat design TBD; post–vertical slice adventure milestone |
| Stamina / energy | Not tied to sprint |
| Carry-weight slowdown | Not in M1 |
| Controller remapping UI | Input Map defaults only |
| Camera redesign | Existing `Camera2D` child unchanged by this spec |
| Final player sprite sheets | Placeholder OK |

---

## Implementation follow-ups (for directing AI)

Candidate tickets after this spec is approved (do not open from this doc ticket):

1. ~~Implement sprint input + multiplier on `player.gd` per this spec~~ (done)
2. ~~Implement movement-lock API and migrate `RegionManager` busy gating to a named lock~~ (done; ADR-007 Accepted)
3. Expose animation contract getters / movement-state enum; keep placeholder bob until art arrives
4. Wire dialogue / menu / fishing systems to acquire/release locks when those features are built
5. Basic NPC collision policy ticket (not part of movement implementation alone)

---

## Open playtesting knobs

Safe to tune without a new design doc:

- `move_speed` (default 110)
- `sprint_multiplier` (default 1.6)
- Exact gamepad binding for `sprint`
