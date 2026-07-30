# Core Systems

## Player Movement

Authoritative Milestone 1 detail: [`docs/design/player_movement.md`](../design/player_movement.md).

- Walk in eight directions.
- Sprint/run using a stamina-free movement boost.
- Smooth transitions between walking, running, riding, and interacting.
- Automatic region transitions when reaching map exits.
- Collision with terrain, buildings, NPCs, and obstacles.
- Context-sensitive interactions with objects and NPCs.
- Basic player animations for idle, movement, tool use, fishing, combat, and carrying items.

### Tool Usage

- Equip and switch between tools.
- Use farming tools (hoe, watering can, axe, pickaxe, shovel, scythe).
- Use fishing rod at designated fishing locations.
- Harvest resources from the environment.
- Tool upgrades unlock new interactions and previously inaccessible areas.

### Combat

- Equip and switch weapons.
- Basic melee attacks.
- Block or dodge (final design TBD).
- Damage enemies and environmental hazards.
- Defeat enemies for resources and progression.
- Combat only in designated wilderness and dangerous regions.

### Mounts

- Unlock rideable animals through progression.
- Faster travel than running.
- Mount and dismount seamlessly.
- Access certain areas more efficiently.
- Cosmetic mount customization (future).

### Interactions

- Talk to NPCs.
- Open doors and buildings.
- Collect items from the world.
- Activate restoration projects.
- Read signs, books, and journals.
- Trigger story events and cutscenes.

## Camera

- Fixed 2D top-down camera that follows the player smoothly.
- Keep the player centered during normal exploration.
- Support simple camera pans and zooms for cutscenes, story moments, and restorations.
- Brief cinematic camera movement for major discoveries, region reveals, and important events.
- Fade-to-black transitions between world regions.

## Inventory

- Quick-access hotbar for equipped tools and commonly used items.
- Expandable backpack that increases inventory capacity through upgrades.
- Organized inventory for resources, tools, equipment, food, quest items, and collectibles.
- Storage chests for organizing items at the farm and other player-owned locations.
- Simple item management with easy transfer between inventory and storage.

## Save System

- Save progress automatically at the end of each in-game day.
- Resume from the beginning of the most recently completed day.
- Multiple save slots for different playthroughs.
- Simple load, overwrite, and delete save management from the main menu.

## Dialogue

- Speak with NPCs through text-based conversations.
- Character portrait and dialogue box displayed during conversations.
- No voice acting; personality conveyed through writing, animations, and sound effects.
- Dialogue choices allow players to shape conversations and relationships.
- Special dialogue unlocked through friendship, story progression, and completed restorations.

## Day & Night Cycle

- Dynamic day and night cycle that progresses each in-game day.
- Longer daylight hours during summer; shorter days in fall and winter.
- Time of day affects lighting, NPC schedules, shop hours, and ambience.
- Players can stay awake past midnight, but doing so causes reduced energy the following day.
- Sleeping ends the day, advances the calendar, and saves game progress.

## Time System

- Each in-game day follows a 24-hour clock.
- The player wakes up at **6:00 AM** each morning.
- One in-game day lasts approximately **20 minutes** of real time.
- Time advances continuously during gameplay, driving NPC schedules, shop hours, events, and world activities.
- Sleeping advances to the next day and resets the daily schedule.


# Gameplay

## Fishing

**Description:**  
Players can fish from beaches, docks, rivers, lakes, boats, and other fishing locations throughout the island. Fishing is one of the ways to earn money, discover rare collectibles, and complete quests.

### Major Tasks

- Fishing minigame
- Fish database / collection log
- Rod upgrades
- Bait system
- Treasure catches
- Legendary fish
- Region-specific fish species
- Time-of-day and seasonal fish availability
- Fishing quests and NPC requests
- Fishing tournaments and events
- Boat fishing
```

## Farming

**Description:**  
Players can grow crops, raise animals, and develop their homestead into a productive farm. Farming provides food, crafting materials, gifts, and a reliable source of income throughout the game.

### Major Tasks

- Crop planting and harvesting
- Watering and crop care
- Seasonal crops
- Fruit trees
- Livestock (chickens, cows, goats, pigs, etc.)
- Animal products
- Farm expansion
- Irrigation upgrades
- Fertilizer system
- Crop quality levels
- Farm buildings
- Automation upgrades (late game)
- Crop shipping and selling
```

## Mining

**Description:**  
Players explore mines and caves to gather ores, gems, stone, and rare resources needed for crafting, tool upgrades, restorations, and story progression. Deeper levels contain greater rewards and increased danger.

### Major Tasks

- Mine exploration
- Resource gathering
- Ore and gem collection
- Mine progression
- Cave hazards
- Combat encounters
- Tool upgrades
- Mine restoration
- Rare minerals and artifacts
- Elevator/checkpoint system
- Explosives
- Secret rooms
- Story-related discoveries
- Desert cave exploration
```

## Cooking

**Description:**  
Players can prepare meals using ingredients gathered, farmed, fished, or purchased. Cooked dishes restore energy, provide temporary buffs, make excellent gifts, and can be sold for profit.

### Major Tasks

- Recipe collection
- Cooking station
- Ingredient combinations
- Energy restoration
- Temporary food buffs
- Restaurant and café requests
- Festival cooking events
- High-value gourmet dishes
- NPC favorite meals
- Cooking achievements
```

## Crafting

**Description:**  
Players craft tools, equipment, furniture, building materials, and restoration supplies using resources gathered throughout the island. Crafting supports progression by unlocking new capabilities and improving efficiency.

### Major Tasks

- Crafting recipes
- Crafting stations
- Tool crafting and upgrades
- weapons
- Building materials
- Furniture and decorations
- Restoration materials
- Equipment crafting
- Resource processing (bars, lumber, bricks, etc.)
- Storage items
- Unlockable recipes
- Crafting quests
- Rare and advanced recipes
```
## Trading

**Description:**  
Players earn money by selling gathered resources, crafted goods, crops, fish, and artisan products. Can also receive income by dividends from constructed projects (toll bridge, fishing enterprise, energy plant). Most items can be sold through the farm shipping bin, while special requests and local merchants offer opportunities for greater profits.

### Major Tasks

- Farm shipping bin
- Buy and sell with merchants
- Special item requests
- Premium contracts for higher payouts
- Merchant inventory
- Dynamic item pricing
- Relationship-based shop discounts
- Regional merchants
- Import and specialty goods
- Harbor trade expansion
- Late-game exports
```
# NPC

## NPC System

**Description:**  
NPCs bring Puerto Ventura to life through daily routines, friendships, quests, businesses, and festivals. As the island is restored, new residents arrive, existing residents expand their routines, and relationships deepen over time.

### Major Tasks

- Daily schedules
- Relationships
- Gift system
- Festivals and community events
- Dialogue progression
- Friendship events
- Romance
- Marriage / Families
- NPC quests and requests
- Shop ownership
- NPC homes and routines
- New residents arriving through restoration
- Character portraits
- Birthday events
- Gossip and dynamic conversations
```
