# LediBug Cell Types Reference

## Overview
This document describes all cell types available in LediBug levels, including their behavior, ASCII representation, colors, and implementation status.

## Cell Types

### Basic Navigation Cells

| Type | Char | Color | Status | Description |
|------|------|-------|--------|-------------|
| EMPTY | `.` | Dark Gray | ✅ Implemented | Walkable empty space |
| WALL | `#` | Blue-Gray | ✅ Implemented | Blocks movement |
| START | `S` | Yellow | ✅ Implemented | Player spawn point |
| GOAL | `G` | Green | ✅ Implemented | Level completion |

### Hazard Cells

| Type | Char | Color | Status | Description |
|------|------|-------|--------|-------------|
| HAZARD | `X` | Red | ✅ Implemented | Generic hazard - player dies |
| LAVA | `L` | Orange-Red | ✅ Added | Instant death, visual lava effect |
| WATER | `W` | Blue | ✅ Added | Blocks movement unless player has bridge |

### Special Movement Cells

| Type | Char | Color | Status | Description |
|------|------|-------|--------|-------------|
| TELEPORTER | `T` | Magenta | ✅ Implemented | Transports to paired teleporter |
| ICE | `I` | Light Blue | ✅ Added | Player slides until hitting wall/edge |
| SPRING | `^` | Light Green | ✅ Added | Launches player 2 cells forward |
| ARROW | `>` | Cyan | ✅ Added | Forces player direction change |

### Interactive Cells

| Type | Char | Color | Status | Description |
|------|------|-------|--------|-------------|
| SWITCH | `$` | Yellow | ✅ Added | Toggles linked doors/walls |
| DOOR | `D` | Brown | ✅ Added | Blocks movement until opened |
| KEY | `K` | Gold | ✅ Added | Collectible to open doors |

### Collectibles

| Type | Char | Color | Status | Description |
|------|------|-------|--------|-------------|
| COIN | `o` | Gold-Yellow | ✅ Added | Collectible for points |
| GEM | `*` | Purple | ✅ Added | Rare collectible, bonus points |

### Utility Cells

| Type | Char | Color | Status | Description |
|------|------|-------|--------|-------------|
| CHECKPOINT | `C` | Green | ✅ Added | Save point in level |
| TRAP | `!` | Dark Red | ✅ Added | Activates after N steps |

## Teleporter System

### How Teleporters Work

1. **Pairing**: Teleporters are automatically paired in order of appearance in the level layout
   - 1st T ↔ 2nd T
   - 3rd T ↔ 4th T
   - 5th T ↔ 6th T
   - etc.

2. **Behavior**: When player steps on a teleporter, they are instantly transported to its pair

3. **Implementation**: 
   - Grid manager tracks teleporter pairs
   - Cell properties store target positions
   - Player automatically teleports when entering cell

### Example Level with Teleporters

```
##########
#S.......#
#.T....T.#  <- First pair
#........#
#...##...#
#........#
#.T....T.#  <- Second pair
#.......G#
##########
```

## Player Inventory System

### Available Functions

```gdscript
# Check if player has an item
has_item("bridge")  # Returns true/false

# Add item to inventory
add_item("key_red")

# Use/consume an item
use_item("bridge")  # Returns true if used, false if not in inventory

# Clear all items
clear_inventory()
```

### Inventory Items

- `bridge` - Allows crossing WATER cells
- `key_red`, `key_blue`, etc. - Opens matching colored doors
- Items collected via KEY cells or programmatically

## New Player Sensor Functions

### Cell Type Detection

```gdscript
# Check current cell type
is_on_water()       # Returns bool
is_on_ice()         # Returns bool
is_on_teleporter()  # Returns bool

# Get cell type as string
get_cell_type()     # Returns "EMPTY", "WALL", "TELEPORTER", etc.
```

### Existing Sensors (Still Available)

```gdscript
frontIsClear()      # Check if can move forward
leftIsClear()       # Check if can turn left and move
rightIsClear()      # Check if can turn right and move
goalReached()       # Check if standing on goal
onHazard()          # Check if standing on hazard
```

## Implementation Status

### ✅ Fully Implemented
- TELEPORTER - Auto-pairing, instant transport, working in levels 9-10
- Cell type enum (all 18 types)
- Color mapping for all types
- ASCII parser (from_char, to_char)
- Player inventory system
- New sensor functions

### 🚧 Added but Not Fully Functional
- ICE, WATER, LAVA, SPRING, ARROW, TRAP - Cell types exist but behavior not implemented
- SWITCH, DOOR, KEY - Infrastructure added but toggle logic not implemented
- COIN, GEM, CHECKPOINT - Can be placed but no collection logic

### 📋 Next Steps
1. Implement ICE sliding mechanics
2. Add SWITCH/DOOR toggling system
3. Implement KEY collection and door unlocking
4. Add visual effects for teleportation
5. Create more levels showcasing new cell types
6. Add particle effects for LAVA
7. Implement SPRING jumping
8. Add ARROW directional forcing

## Example Level Designs

### Portal Puzzle (Level 9)
```
##########
#S.......#
#........#
#..T..T..#  <- Teleporter pair
#........#
#...##...#
#........#
#..T..T..#  <- Another pair
#.......G#
##########
```

### Water Crossing (Future)
```
##########
#S.......#
#.K......#  <- Pick up key (bridge)
#........#
#..WWWW..#  <- Water (requires bridge)
#........#
#........#
#.......G#
##########
```

### Ice Sliding (Future)
```
##########
#S.......#
#.IIIIII.#  <- Ice surface
#.I....I.#
#.I.##.I.#
#.I....I.#
#.IIIIII.#
#.......G#
##########
```

## Color Palette

For reference when creating visual assets:

| Cell Type | Hex Color | RGB |
|-----------|-----------|-----|
| TELEPORTER | #CC00CC | (204, 0, 204) |
| WATER | #3366E6 | (51, 102, 230) |
| LAVA | #FF4D00 | (255, 77, 0) |
| ICE | #99CCFF | (153, 204, 255) |
| SWITCH | #E6E619 | (230, 230, 25) |
| DOOR | #996633 | (153, 102, 51) |
| KEY | #FFD700 | (255, 215, 0) |
| COIN | #FFE633 | (255, 230, 51) |
| GEM | #8000E6 | (128, 0, 230) |

## API Reference

### GridManager Methods

```gdscript
# Cell property management
set_cell_property(pos: Vector2i, key: String, value)
get_cell_property(pos: Vector2i, key: String, default = null)
has_cell_property(pos: Vector2i, key: String) -> bool

# Teleporter methods
get_teleporter_target(pos: Vector2i) -> Vector2i
is_teleporter(grid_pos: Vector2i) -> bool

# Signals
signal cell_activated(cell_pos: Vector2i, cell_type: CellType.Type)
signal item_collected(item_type: CellType.Type, position: Vector2i)
signal teleported(from_pos: Vector2i, to_pos: Vector2i)
```

### Player Methods

```gdscript
# Inventory
has_item(item_name: String) -> bool
add_item(item_name: String)
use_item(item_name: String) -> bool
clear_inventory()

# Sensors
is_on_water() -> bool
is_on_ice() -> bool
is_on_teleporter() -> bool
get_cell_type() -> String

# Signals
signal item_collected(item_name: String)
signal teleported(from_pos: Vector2i, to_pos: Vector2i)
```

---

**Last Updated**: 2026-02-17  
**Version**: 1.0  
**Status**: Teleporter system fully functional, other cell types pending implementation
