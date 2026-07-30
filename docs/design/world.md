# World

## Structure

The island is a **large interconnected map** split into **modular regions**. Regions do not all stay loaded; each is its own scene and loads independently.

## Navigation

Player walks to a map-edge exit → fade to black → neighbor region loads → player spawns at destination → fade in.

Benefits: larger world, better performance, independent editing, modular expansion.

## Region graph (v1)

Registered ids today include: `beach`, `harbor`, `city`, `jungle`, plus locked late-game areas (volcano, deep jungle, ancient city, desert, desert cave, rocky mining, cursed area, mountain, mountain summit).

Starting unlocked (prototype): Beach, Harbor, City, Jungle.

## Beach layout intent (hand sketch)

- Sand shoreline with water on west/south
- Lighthouse on the west (island + bridge)
- Central winding road
- Dock on the southeast
- Scattered beach buildings
- **North exit:** farm / home
- **East exit:** town area

## Farm / home

Separate region from Beach shoreline. Player house and light farming.

## Unlock philosophy

Late regions open through restoration and story gates—not permanent hard locks forever.

## Story delivery

Environmental storytelling first: ruins, abandoned shops, blocked paths, restored landmarks. Major revelations concentrate toward late regions (mountain summit, ancient city, cursed area).
