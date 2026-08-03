# Puerto Ventura Vertical Slice

## Purpose

This vertical slice is a tightly scripted 5–10 minute playable sequence designed to prove the core fantasy of **Puerto Ventura**:

> The player arrives on a neglected island, begins surviving, helps one resident restore a livelihood, creates the first visible economic improvement, and discovers evidence that the island hides a larger mystery.

The slice must demonstrate:

- Character movement and interaction
- Dialogue and event sequencing
- Day transition and sleeping
- Inventory and tool acquisition
- Farming basics
- Fishing basics
- Resource gathering
- Light combat
- Quest tracking
- NPC rewards and trades
- Environmental restoration
- Visible economic progression
- Archaeology foreshadowing
- A strong narrative ending

---

# 1. Scope

## Included Areas

1. **Crash Beach**
2. **City Center**
3. **Player Farm**
4. **Player House**
5. **Farm Cave**
6. **Fishing Harbor**
7. **Furniture Workshop**
8. **General Store Exterior / Interior**

## Included NPCs

Use placeholder names until final names are approved.

| ID | Role | Placeholder Name |
|---|---|---|
| `npc_fisherman` | Fisherman and first rescuer | Mateo |
| `npc_storekeeper` | General store owner | Elena |
| `npc_furniture_maker` | Lumber and furniture craftsperson | Mara |
| `npc_restaurant_owner` | Restaurant owner; optional introduction | Tomas |
| `npc_cargo_captain` | Visiting cargo captain | Captain Vale |

## Included Systems

- Player movement
- NPC follow/path sequence
- Dialogue boxes
- Quest journal
- Inventory
- Basic item pickup
- Basic farming
- Basic fishing
- Basic resource gathering
- Basic combat using scythe
- Day/night transition
- Sleep interaction
- Cutscenes
- Persistent world-state changes

## Explicitly Out of Scope

- Full economy simulation
- Romance
- NPC schedules beyond scripted slice behavior
- Advanced combat
- Tool upgrades
- Cooking
- Crafting menus
- Skill trees
- Full save/load support beyond slice checkpointing
- Large open-world exploration

---

# 2. High-Level Event Flow

```text
EVT_001 Intro Cinematic
    ↓
EVT_002 Wake on Crash Beach
    ↓
EVT_003 Fisherman Escort to City Center
    ↓
EVT_004 Meet Storekeeper
    ↓
EVT_005 Travel to Rundown House
    ↓
EVT_006 Sleep / Day Transition
    ↓
EVT_007 Storekeeper Supply Delivery
    ↓
QST_001 First Morning Tasks
    ├── Farm Tutorial
    ├── Meet Fisherman
    ├── Meet Furniture Maker
    └── Optional: Meet Restaurant Owner
            ↓
QST_002 Restore the Fishing Boat
    └── Gather 30 Wood
            ↓
QST_003 A Proper Bed
    └── Enter Farm Cave
        ├── Fight Bats / Spiders
        ├── Recover Lost Item
        └── Trigger Archaeology Foreshadowing
            ↓
QST_004 Fifteen Extra Fish
    └── Catch and Deliver 15 Fish
            ↓
EVT_008 Sleep / Cargo Arrival
    ↓
EVT_009 Cargo Captain Cutscene
    ├── Contract fulfilled
    ├── Harbor crate appears
    └── Mysterious package delivered
            ↓
EVT_010 Notebook Reveal / End Slice
```

---

# 3. Global State Flags

Use these flags to prevent sequence breaks and duplicate events.

```gdscript
intro_cinematic_complete = false
player_washed_ashore = false
fisherman_beach_intro_complete = false
city_center_intro_complete = false
storekeeper_intro_complete = false
player_house_unlocked = false
first_sleep_complete = false
starter_supplies_received = false
farm_tutorial_complete = false
fisherman_met = false
furniture_maker_met = false
restaurant_owner_met = false
boat_repair_quest_started = false
boat_repair_quest_complete = false
bed_quest_started = false
bed_quest_complete = false
cave_mystery_triggered = false
fish_contract_started = false
fish_contract_complete = false
cargo_arrival_scheduled = false
cargo_arrival_complete = false
mysterious_package_delivered = false
vertical_slice_complete = false
```

---

# 4. Required Items

| Item ID | Display Name | Use |
|---|---|---|
| `item_backpack` | Backpack | Unlocks inventory expansion or inventory UI |
| `tool_hoe_basic` | Worn Hoe | Tills farm soil |
| `tool_watering_can_basic` | Watering Can | Waters planted seeds |
| `tool_scythe_basic` | Rusted Scythe | Clears weeds and functions as cave weapon |
| `tool_fishing_rod_basic` | Fishing Rod | Catches fish |
| `seed_tomato` | Tomato Seeds | Farming tutorial |
| `resource_wood` | Wood | Boat repair quest |
| `quest_mara_lost_item` | Brass Locket / Carving Tool | Returned to furniture maker |
| `fish_common` | Common Fish | Used for fisherman sales and cargo contract |
| `item_simple_bed` | Simple Bed | Installed in player house |
| `item_mysterious_notebook` | Weathered Notebook | Ending mystery object |

---

# 5. Detailed Event Sequences

## EVT_001 — Intro Cinematic

### Objective

Establish the crash, the island, and the player's arrival without lengthy exposition.

### Trigger

- New game selected
- `intro_cinematic_complete == false`

### Sequence

1. Show aircraft traveling over ocean.
2. Show sudden mechanical failure or severe weather.
3. Brief, non-interactive crash sequence.
4. Fade to black.
5. Play ocean audio.
6. Fade in on player lying on beach.

### Completion

Set:

```gdscript
intro_cinematic_complete = true
player_washed_ashore = true
```

### Acceptance Criteria

- Player input is disabled during the cinematic.
- Cinematic can be skipped.
- Skipping places the player at the exact start position for `EVT_002`.
- No gameplay-critical state is lost by skipping.

---

## EVT_002 — Fisherman Wakes the Player

### Trigger

- `player_washed_ashore == true`
- Player is at crash beach spawn point
- `fisherman_beach_intro_complete == false`

### Sequence

1. Fisherman approaches player.
2. Player performs wake-up animation.
3. Fisherman checks whether the player is alive.
4. Dialogue communicates:
   - The player washed ashore.
   - The fisherman saw the crash or found wreckage.
   - The player should come into town.
   - Someone in town may know what to do.
5. Fisherman becomes temporary escort NPC.

### Dialogue Intent

Do not hardcode final prose here. Dialogue should communicate:

- Surprise and concern
- The player is lucky to be alive
- The island is inhabited, but struggling
- The fisherman will lead the player to the city center

### Completion

Set:

```gdscript
fisherman_beach_intro_complete = true
```

Start escort sequence `EVT_003`.

### Acceptance Criteria

- Player cannot leave the beach before the fisherman interaction completes.
- Fisherman pathing cannot permanently block the player.
- If player falls too far behind, fisherman waits.
- If player moves too far away, objective marker points toward fisherman.

---

## EVT_003 — Escort to City Center

### Trigger

- `fisherman_beach_intro_complete == true`

### Sequence

1. Fisherman walks from beach to city center.
2. Player follows.
3. Fisherman may use one or two short ambient lines while walking.
4. Camera briefly frames:
   - Damaged storefronts
   - Broken communications tower or antenna
   - Empty docks
   - Neglected public space
5. Fisherman stops near general store.
6. Storekeeper exits or is already waiting.

### Environmental Storytelling Requirements

The walk should show that Puerto Ventura was once active but has declined.

Required visuals:

- Boarded or faded storefront
- Broken communication equipment
- Empty loading area
- Overgrowth
- At least one visibly repairable landmark

### Completion

Set:

```gdscript
city_center_intro_complete = true
```

Start `EVT_004`.

---

## EVT_004 — Meet the Storekeeper

### Trigger

- `city_center_intro_complete == true`
- `storekeeper_intro_complete == false`

### Sequence

1. Fisherman introduces player to storekeeper.
2. Storekeeper assesses the situation.
3. Dialogue communicates:
   - The island cannot send the player home soon.
   - Supply shipments arrive approximately once per month.
   - Long-range communications have not worked for some time.
   - The player will need to remain on the island temporarily.
   - A rundown house west of town is available.
   - Storekeeper will visit in the morning with supplies.
4. Fisherman leaves scripted sequence.
5. Quest objective becomes: `Go to the rundown house and sleep.`

### Completion

Set:

```gdscript
storekeeper_intro_complete = true
player_house_unlocked = true
```

### Acceptance Criteria

- Player house door becomes interactable only after this event.
- Objective marker updates to player house.
- Player cannot accidentally start morning quests before sleeping.

---

## EVT_005 — First Night at the House

### Trigger

- Player enters house
- `player_house_unlocked == true`
- `first_sleep_complete == false`

### House State

The house should contain:

- Bare floor
- Broken or missing furniture
- Sleeping spot represented by blanket, mat, or floor marker
- One interactable sleep location

### Sequence

1. Player interacts with floor sleeping spot.
2. Confirmation prompt appears.
3. Fade to black.
4. Advance to next morning.
5. Restore player energy if energy exists.

### Completion

Set:

```gdscript
first_sleep_complete = true
```

Start `EVT_006` or `EVT_007` on wake.

---

## EVT_006 — Storekeeper Delivers Supplies

### Trigger

- `first_sleep_complete == true`
- Player wakes inside house
- `starter_supplies_received == false`

### Sequence

1. Knock or door sound.
2. Storekeeper enters or waits outside.
3. Dialogue communicates:
   - Player needs to sustain themselves.
   - Player will need goods to trade.
   - Supplies are being provided on credit.
   - Player can repay later if they remain on the island.
   - Furniture maker may have a spare bed.
   - Fisherman can help the player begin earning money.
   - Player should meet key residents.
4. Grant starter items.

### Starter Inventory

```text
Backpack
Hoe
Watering Can
Scythe
Fishing Rod
6 Tomato Seeds
```

### Design Note

The current outline references receiving a fishing pole from the storekeeper and also asking the fisherman for a spare rod. Use one of these implementations:

**Recommended implementation:**

- Storekeeper provides a damaged or basic rod.
- Fisherman teaches fishing and officially unlocks use of the rod.

Alternative:

- Storekeeper does not provide a rod.
- Fisherman gives the rod during first meeting.

For this slice, use the recommended implementation to avoid inventory inconsistency.

### Quest Unlocks

Start `QST_001 — First Morning Tasks`.

Set:

```gdscript
starter_supplies_received = true
```

---

# 6. Quest Specifications

## QST_001 — First Morning Tasks

### Purpose

Teach the player the basic controls and direct them toward the slice's three core NPCs.

### Quest Objectives

```text
[ ] Till 3 soil tiles
[ ] Plant 3 seeds
[ ] Water 3 planted seeds
[ ] Speak with the fisherman
[ ] Speak with the furniture maker
[ ] Speak with the restaurant owner
```

The restaurant objective may be optional if total playtime exceeds ten minutes.

### Farming Tutorial Criteria

#### Till Soil

- Player equips hoe.
- Player uses hoe on valid farm soil.
- Count only newly tilled tiles.

#### Plant Seeds

- Player equips tomato seeds.
- Player plants seeds in tilled soil.
- Count only successfully planted seeds.

#### Water Seeds

- Player equips watering can.
- Player waters planted crops.
- Count each planted crop once.

### Completion

Set:

```gdscript
farm_tutorial_complete = true
```

Quest may remain active until all required NPC introductions are complete.

### Acceptance Criteria

- Objectives update immediately.
- Invalid actions do not increment counters.
- Player cannot consume or lose all tutorial seeds before planting three.
- Provide fallback seeds if inventory count drops below required amount.

---

## QST_002 — Restore the Fishing Boat

### Quest Giver

`npc_fisherman`

### Prerequisite

- `starter_supplies_received == true`
- Player speaks to fisherman

### Intro Sequence

Fisherman explains:

- He will purchase fish the player catches.
- Fishing is the player's fastest way to earn money.
- His own boat is damaged.
- Repairing the boat would allow him to resume offshore fishing.
- He needs 30 wood.

### Quest Objectives

```text
[ ] Gather 30 Wood
[ ] Deliver 30 Wood to the fisherman
```

### Wood Sources

- Farm debris
- Small trees or fallen branches
- Pre-placed wood piles

Do not require advanced tree chopping unless an axe is added to the starter kit.

### Recommended Implementation

Because the current tool list does not include an axe, use:

- Scythe clears brush and small branches.
- Cleared branches drop wood.
- Pre-placed driftwood piles can be collected.

### Delivery Sequence

1. Player speaks with fisherman while carrying at least 30 wood.
2. Confirm delivery.
3. Remove 30 wood.
4. Play short repair montage or overnight repair transition.
5. Replace broken boat world object with restored boat variant.
6. Fisherman reacts positively.

### World-State Change

Before completion:

- Boat has damaged sprite/model.
- Boat cannot move.
- Harbor feels inactive.

After completion:

- Boat appears repaired.
- Fisherman may stand beside it.
- Boat may leave and return during a brief scripted animation.
- Fishing harbor gains one new ambient effect, such as nets, crates, or gulls.

### Completion

Set:

```gdscript
fisherman_met = true
boat_repair_quest_started = true
boat_repair_quest_complete = true
```

Unlock `QST_004 — Fifteen Extra Fish`.

---

## QST_003 — A Proper Bed

### Quest Giver

`npc_furniture_maker`

### Prerequisite

- `starter_supplies_received == true`

### Intro Sequence

Furniture maker explains:

- She has a spare bed or can assemble one.
- She lost an important personal or professional object in the cave near the player's farm.
- Bats or spiders frightened her, causing her to flee.
- She will trade the bed for the returned object.

### Recommended Lost Object

Use one object with both emotional and visual clarity.

Recommended:

```text
Item: Brass Carving Compass
Description: A worn brass measuring tool inherited from her mother.
```

Alternative:

```text
Item: Family Locket
```

The carving compass better supports the furniture craftsperson role and can contain an unfamiliar symbol that connects subtly to the archaeology plot.

### Quest Objectives

```text
[ ] Enter the farm cave
[ ] Defeat or avoid cave creatures
[ ] Recover Mara's lost carving compass
[ ] Exit the cave
[ ] Return the item to Mara
```

### Cave Combat Requirements

- Player uses scythe as melee weapon.
- Include 2–4 total enemies.
- Enemy types:
  - Bats
  - Spiders
- Combat should be simple and low-risk.
- Player should not be able to permanently fail the slice.

### Cave Layout

The cave should contain:

1. Entrance chamber
2. Small combat chamber
3. Lost-item chamber
4. Exit corridor with hidden floor button

### Archaeology Foreshadowing Event

#### Trigger

- Player has collected `quest_mara_lost_item`
- Player is leaving the cave
- Player steps on concealed pressure plate
- `cave_mystery_triggered == false`

#### Sequence

1. Stone pressure plate depresses.
2. Low mechanical rumble plays.
3. Nearby wall symbols briefly illuminate or shift.
4. A sealed stone section opens slightly or reveals a narrow recess.
5. Inside is one of the following:
   - A metallic surface embedded in ancient stone
   - A star-map pattern
   - A symbol matching the carving compass
   - A light source with no visible fuel
6. The opening closes before the player can enter.
7. One small artifact shard or visual marker remains.
8. Quest log adds optional note:
   - `Something moved beneath the cave wall.`

### Important Tone

The moment should feel strange, not overtly supernatural.

Avoid:

- Monsters appearing from portals
- Explicit alien imagery
- Large exposition text
- Immediate explanation

### Bed Reward Sequence

1. Return lost item to furniture maker.
2. Furniture maker accepts item.
3. Grant or schedule installation of `item_simple_bed`.
4. Bed appears in player house.
5. Original floor sleeping spot is removed or disabled.

### Completion

Set:

```gdscript
furniture_maker_met = true
bed_quest_started = true
bed_quest_complete = true
cave_mystery_triggered = true
```

---

## QST_004 — Fifteen Extra Fish

### Quest Giver

`npc_fisherman`

### Prerequisite

- `boat_repair_quest_complete == true`

### Intro Sequence

Fisherman explains:

- A cargo captain is expected soon.
- The fisherman has an opportunity to fulfill a fish contract.
- He is short by 15 fish.
- Completing the order could convince the captain to return more often.

### Quest Objectives

```text
[ ] Catch 15 fish
[ ] Deliver 15 fish to the fisherman
[ ] Sleep until the cargo ship arrives
```

### Fish Counting Rules

Count only eligible fish.

Recommended eligible fish tag:

```gdscript
item.has_tag("cargo_contract_fish")
```

Do not require 15 different species.

### Demo Pacing Requirements

Fishing 15 full fish may take too long for a 5–10 minute slice. Use one or more of these accelerators:

- Fast bite rate during active quest
- Simplified fishing minigame
- Fishing spots produce multiple fish
- Fisherman already has part of the order and only needs 5–8 player-caught fish, while the quest fiction still references a 15-fish shipment
- Scripted time compression

### Recommended Implementation

For playable pacing:

```text
Contract total: 15 fish
Fisherman contribution: 10 fish
Player requirement: 5 fish
```

The shipment still contains 15 fish, but the player only needs to catch five during the slice.

If the build is intended for a longer 15–20 minute demo, require all 15.

### Delivery Sequence

1. Player delivers required fish.
2. Fisherman confirms contract is ready.
3. Cargo arrival is scheduled for next morning.
4. Objective updates to `Sleep until tomorrow.`

### Completion

Set:

```gdscript
fish_contract_started = true
fish_contract_complete = true
cargo_arrival_scheduled = true
```

---

# 7. Cargo Arrival Finale

## EVT_008 — Sleep Before Cargo Arrival

### Trigger

- `cargo_arrival_scheduled == true`
- Player sleeps in installed bed or temporary sleep location

### Sequence

1. Fade to black.
2. Advance to next morning.
3. Play ship horn before player regains control.
4. Display objective: `Go to the harbor.`

### Acceptance Criteria

- Cargo event does not begin until player reaches harbor trigger.
- Ship horn can be heard from the player's house.
- Harbor NPCs are positioned before player enters the scene.

---

## EVT_009 — Cargo Captain Arrives

### Trigger

- Player enters harbor event zone
- `cargo_arrival_scheduled == true`
- `cargo_arrival_complete == false`

### Sequence

1. Disable player movement.
2. Cargo vessel approaches or is revealed at dock.
3. Cargo captain steps onto dock.
4. Fisherman presents fish shipment.
5. Captain inspects the shipment.
6. Dialogue communicates:
   - The fish quality is exceptional.
   - The captain did not expect Puerto Ventura to fulfill the order.
   - There may still be commercial potential on the island.
   - The captain may return if future shipments are reliable.
7. Captain orders crew to unload a large supply crate.
8. Crate is placed visibly on harbor dock.
9. Harbor world state changes.

### Required World-State Change

Spawn persistent object:

```text
Large Imported Cargo Crate
```

The crate represents the first visible improvement to the island's economy.

Optional supporting changes:

- New sacks or barrels beside crate
- General store receives one new exterior sign or stocked shelf
- Additional dock worker appears
- Harbor ambience becomes slightly busier

### Completion

Set:

```gdscript
cargo_arrival_complete = true
```

Continue directly into mysterious package sequence.

---

## EVT_010 — Mysterious Package and Notebook Reveal

### Trigger

- Cargo contract scene complete
- `mysterious_package_delivered == false`

### Sequence

1. Cargo captain pauses before returning to ship.
2. Captain retrieves a weathered package.
3. Captain gives package to fisherman.
4. Captain explains only that:
   - The package was found in old cargo storage, a dead-letter office, or another port archive.
   - It is addressed to someone in Puerto Ventura.
   - The name or date is wrong, incomplete, or impossible.
5. Fisherman opens package after brief hesitation.
6. Inside is a weathered notebook.
7. Notebook cover contains a symbol matching the cave mechanism or the furniture maker's carving compass.
8. A loose page or map falls out.
9. The map points toward the deeper jungle, mountain, or another inaccessible area.
10. Show one brief notebook excerpt without explaining it fully.

### Recommended Final Text Fragment

Use a concise, original line such as:

> Do not send anyone from the university. The chamber is not beneath the ruins. It is beneath the island.

Do not reveal the corpse, high-tech city, ancient civilization, or Cartographer in the vertical slice.

### Final Shot

Recommended framing:

1. Close-up of notebook symbol.
2. Match cut to same symbol faintly glowing in the farm cave.
3. Cut to black.
4. Display game title.
5. Display call to action:
   - `Wishlist Puerto Ventura`

### Completion

Set:

```gdscript
mysterious_package_delivered = true
vertical_slice_complete = true
```

---

# 8. Quest Dependency Graph

```text
START
  |
  v
Intro Cinematic
  |
  v
Beach Rescue
  |
  v
City Center Introduction
  |
  v
First Sleep
  |
  v
Starter Supplies
  |
  +-----------------------------+
  |                             |
  v                             v
Farm Tutorial                Meet NPCs
                                |
                  +-------------+-------------+
                  |                           |
                  v                           v
          Restore Fishing Boat          Recover Lost Item
                  |                           |
                  v                           v
          Fish Contract Unlocks          Bed Installed
                  |
                  v
           Complete Contract
                  |
                  v
               Sleep
                  |
                  v
          Cargo Captain Arrives
                  |
                  v
        Mysterious Notebook Reveal
                  |
                  v
                 END
```

---

# 9. Soft Locks and Fail-Safes

## Inventory Fail-Safes

- Starter tools cannot be sold, discarded, or destroyed.
- Quest items cannot be sold or discarded.
- If tutorial seeds are lost, storekeeper provides replacements.
- If player inventory is full during a quest reward, send reward to house storage or force-open reward slot.

## Quest Fail-Safes

- Required NPCs remain accessible during active quests.
- Fisherman cannot leave harbor while player must deliver wood or fish.
- Furniture maker remains at workshop until bed quest is complete.
- Cave enemies respawn only if needed, but lost quest item never respawns after pickup.
- Pressure plate event triggers only once.

## Navigation Fail-Safes

- Add objective markers for:
  - Player house
  - Fisherman
  - Furniture workshop
  - Farm cave
  - Harbor
- If escort NPC pathing fails, teleport NPC to next waypoint after timeout.

## Combat Fail-Safes

- If player health reaches zero in cave:
  - Respawn at cave entrance.
  - Preserve quest progress.
  - Restore enough health to retry.
- Do not end demo on death.

## Pacing Fail-Safes

- Wood drop rate should guarantee 30 wood from nearby farm debris.
- Fishing bite rate should be increased during contract quest.
- Player should not need to wait through a full real-time day.
- Sleep should always be available once required objectives are complete.

---

# 10. Suggested Runtime Targets

| Segment | Target Duration |
|---|---:|
| Intro cinematic | 20–30 seconds |
| Beach rescue and walk to town | 45–60 seconds |
| Storekeeper introduction and first sleep | 45–60 seconds |
| Supply delivery and tutorial | 60–90 seconds |
| Boat repair quest | 60–90 seconds |
| Cave and bed quest | 90–120 seconds |
| Fish contract | 60–90 seconds |
| Cargo finale and mystery reveal | 60–90 seconds |

### Total Target

```text
Minimum: 7 minutes
Ideal: 9–12 minutes
Maximum: 15 minutes
```

A true five-minute version should reduce:

- Wood requirement from 30 to 10
- Player fish contribution from 15 to 3–5
- Cave enemies to two
- NPC introductions to fisherman and furniture maker only

---

# 11. Acceptance Criteria for the Complete Slice

The vertical slice is complete when all conditions below are satisfied.

## Narrative

- Player understands why they cannot immediately leave the island.
- Player receives a plausible temporary home.
- Player meets at least three residents.
- Player helps restore one resident's livelihood.
- Cargo arrival demonstrates renewed outside-world interest.
- Notebook ending establishes a larger mystery.

## Gameplay

- Player tills, plants, and waters crops.
- Player gathers wood.
- Player catches fish.
- Player fights at least one cave enemy.
- Player completes at least two NPC quests.
- Player sleeps and advances the day.

## World Transformation

- Fisherman's boat changes from broken to repaired.
- Player house gains a bed.
- Harbor gains a large cargo crate.
- At least one ambient harbor element becomes more active.

## Technical

- No required event can trigger twice.
- No quest can become permanently blocked.
- All event states persist through scene transitions.
- Dialogue can be skipped without breaking state.
- Intro cinematic can be skipped without breaking state.
- Player can complete the sequence from new game to ending in one session.

## Market-Test Outcome

The slice should leave players with three clear impressions:

1. **I can rebuild this island.**
2. **My actions visibly change the world.**
3. **Something much stranger is hidden here.**

---

# 12. Recommended Implementation Order for Cursor Agents

## Milestone 1 — State and Event Framework

- Global state flags
- Quest state machine
- Dialogue event hooks
- Cutscene input locking
- Scene transition persistence

## Milestone 2 — Opening Sequence

- Intro cinematic
- Beach wake-up
- Fisherman escort
- Storekeeper introduction
- House unlock
- Sleep transition

## Milestone 3 — Starter Gameplay

- Inventory
- Tool equipping
- Farming actions
- Tutorial objective tracking
- Starter item delivery

## Milestone 4 — NPC Questlines

- Fisherman interaction
- Wood gathering
- Boat repair state swap
- Furniture maker interaction
- Cave quest
- Bed installation

## Milestone 5 — Fishing Contract

- Fishing minigame
- Fish counting
- Contract delivery
- Cargo arrival scheduling

## Milestone 6 — Finale

- Cargo ship cutscene
- Captain dialogue
- Harbor cargo crate
- Mysterious package
- Notebook reveal
- End screen

## Milestone 7 — Polish

- Audio cues
- Camera framing
- Objective markers
- Animations
- Fail-safes
- Pacing tuning
- Bug fixing

---

# 13. Suggested Event Data Structure

Each event should be data-driven where possible.

```gdscript
class_name StoryEvent

var event_id: String
var prerequisites: Array[String]
var completion_flags: Array[String]
var trigger_type: String
var trigger_target: String
var cutscene_id: String
var next_event_id: String
var can_skip: bool = true
var repeatable: bool = false
```

Example:

```gdscript
var cargo_arrival_event = {
    "event_id": "EVT_009_CARGO_ARRIVAL",
    "prerequisites": [
        "fish_contract_complete",
        "cargo_arrival_scheduled"
    ],
    "trigger_type": "enter_zone",
    "trigger_target": "harbor_event_zone",
    "cutscene_id": "cs_cargo_arrival",
    "completion_flags": [
        "cargo_arrival_complete"
    ],
    "next_event_id": "EVT_010_NOTEBOOK_REVEAL",
    "can_skip": true,
    "repeatable": false
}
```

---

# 14. Final Design Principle

Every major action in the slice must create one of two outcomes:

```text
Visible restoration
or
Deeper mystery
```

Avoid adding tasks that only produce currency, XP, or inventory items. The player should repeatedly see that their actions either bring Puerto Ventura back to life or reveal that the island is not what it first appears to be.
