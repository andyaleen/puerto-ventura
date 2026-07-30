# Product Requirements Document (PRD)

# Project Codename: Puerto Ventura

## Vision

Create a cozy, 2D, top-down life simulation inspired by the satisfying progression of games like Stardew Valley, while shifting the primary focus from building a farm to restoring an entire island paradise. The player begins with almost nothing—a small beach cottage and a forgotten town—and gradually transforms abandoned landscapes into thriving communities filled with returning residents, new businesses, friendships, and mysteries waiting to be uncovered.

The game should emphasize exploration, visible world progression, relaxing gameplay loops, meaningful relationships, and long-term goals. Every action should contribute toward making the island feel more alive.

---

# Core Design Pillars

* Exploration is rewarding.
* Every gameplay session visibly improves the world.
* Restoration is more important than expansion.
* NPCs have meaningful lives and evolve alongside the town.
* The island itself tells its story.
* Simple systems combine into deep progression.
* The player always has multiple achievable goals.

---

# World Layout (Highest Priority)

The game world should consist of a **large interconnected map** divided into individual regions.

The regions should **not** all exist simultaneously in memory. Instead, each region is its own scene/map that loads independently.

### World Navigation

The player walks naturally through each area.

At the edge of a map, designated exits transition to neighboring regions.

Transition flow:

Player walks to map exit → Screen fades to black → Next region loads → Fade back in

This structure allows:

* Larger overall world size
* Better performance
* Easier future expansion
* Independent editing of each map
* Modular development

The entire map should be designed so additional regions can easily be added later.

---

# Initial World Regions (Version 1)

## Beach
Player house, starting area, fishing, beach resources, shipwrecks, small dock.

## Beach Harbor
Central coastal hub (internal id: `harbor`). Begins abandoned; evolves with restoration.

## Idyllic City Center
Ancient cultural district (internal id: `city`): museum, town hall, marketplace, festivals.

## Jungle
Dense tropical vegetation, forageables, wildlife, ruins, vine-blocked paths.

## Deep Jungle
More dangerous late-game: temples, rare resources, puzzles.

## Desert
Initially barren; eventually restored into a lush oasis.

## Desert Cave
Mining, crystals, ancient machinery, hidden chambers.

## Rocky Mining Area
Primary mining location with classic tool progression.

## Scary Cursed Part
Dark southeast corner. Locked late-game area.

## Volcano
Northwest volcanic mountain. Locked behind jungle restoration.

## Secret Ancient High Tech Town
Late-game mystery city with ancient technology.

## Mountain
Forests, waterfalls, observatory, cabins, scenic overlooks.

## Mountain Top
Late-game destination with major story revelations.

---

# Core Gameplay Loop

Explore → Gather → Earn → Upgrade tools → Restore buildings → Unlock NPCs → Expand businesses → Reveal history → Unlock regions → Repeat

---

# Systems Roadmap

Resource categories, economy, farming, fishing, mining, restoration projects, town evolution, NPCs, friendship, romance, environmental storytelling, and optional secrets — as outlined in the original design brief.

Fishing is a major pillar. Farming exists but should not dominate. Restoration is the core progression mechanic.
