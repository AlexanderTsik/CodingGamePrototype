extends Node
class_name CellType

# Cell type definitions for the game grid
enum Type {
	EMPTY,       # Can walk through freely
	WALL,        # Blocks movement (player can't move into it)
	HAZARD,      # Player dies if they step on it (spikes, lava, etc.)
	GOAL,        # Completes the level when reached
	START,       # Where player spawns
	WATER,       # Can't cross unless on bridge
	LAVA,        # Instant death (alternative to HAZARD)
	ICE,         # Slide until wall/edge
	TELEPORTER,  # Transport to paired teleporter
	SWITCH,      # Toggle doors/walls
	DOOR,        # Opens with switch or key
	KEY,         # Pickup to unlock doors
	SPRING,      # Jump 2 cells forward
	ARROW,       # Forces direction change
	TRAP,        # Triggers after N steps
	CHECKPOINT,  # Save progress point
	COIN,        # Collect for points
	GEM          # Rare valuable item
}

# Visual colors for each cell type
static func get_color(cell_type: Type) -> Color:
	match cell_type:
		Type.EMPTY:
			return Color(0.1, 0.1, 0.15, 1.0)  # Dark gray
		Type.WALL:
			return Color(0.15, 0.25, 0.45, 1.0)  # Brighter blue-gray
		Type.HAZARD:
			return Color(0.9, 0.1, 0.1, 1.0)  # Bright red
		Type.GOAL:
			return Color(0.1, 0.9, 0.1, 1.0)  # Bright green
		Type.START:
			return Color(0.95, 0.95, 0.3, 1.0)  # Bright yellow
		Type.WATER:
			return Color(0.2, 0.4, 0.9, 1.0)  # Blue
		Type.LAVA:
			return Color(1.0, 0.3, 0.0, 1.0)  # Orange-red
		Type.ICE:
			return Color(0.6, 0.8, 1.0, 1.0)  # Light blue
		Type.TELEPORTER:
			return Color(0.8, 0.0, 0.8, 1.0)  # Magenta
		Type.SWITCH:
			return Color(0.9, 0.9, 0.1, 1.0)  # Yellow
		Type.DOOR:
			return Color(0.6, 0.4, 0.2, 1.0)  # Brown
		Type.KEY:
			return Color(1.0, 0.84, 0.0, 1.0)  # Gold
		Type.SPRING:
			return Color(0.3, 0.9, 0.3, 1.0)  # Light green
		Type.ARROW:
			return Color(0.0, 0.8, 0.8, 1.0)  # Cyan
		Type.TRAP:
			return Color(0.7, 0.1, 0.1, 1.0)  # Dark red
		Type.CHECKPOINT:
			return Color(0.3, 0.8, 0.3, 1.0)  # Green
		Type.COIN:
			return Color(1.0, 0.9, 0.2, 1.0)  # Gold yellow
		Type.GEM:
			return Color(0.5, 0.0, 0.9, 1.0)  # Purple
		_:
			return Color(0.5, 0.5, 0.5, 1.0)  # Gray fallback

# Parse character from level layout string
static func from_char(ch: String) -> Type:
	match ch:
		'#':
			return Type.WALL
		'.':
			return Type.EMPTY
		'S':
			return Type.START
		'G':
			return Type.GOAL
		'X':
			return Type.HAZARD
		'W':
			return Type.WATER
		'L':
			return Type.LAVA
		'I':
			return Type.ICE
		'T':
			return Type.TELEPORTER
		'$':
			return Type.SWITCH
		'D':
			return Type.DOOR
		'K':
			return Type.KEY
		'^':
			return Type.SPRING
		'>':
			return Type.ARROW
		'!':
			return Type.TRAP
		'C':
			return Type.CHECKPOINT
		'o':
			return Type.COIN
		'*':
			return Type.GEM
		_:
			return Type.EMPTY  # Default to empty

# Convert cell type back to character (for serialization)
static func to_char(cell_type: Type) -> String:
	match cell_type:
		Type.WALL:
			return '#'
		Type.EMPTY:
			return '.'
		Type.START:
			return 'S'
		Type.GOAL:
			return 'G'
		Type.HAZARD:
			return 'X'
		Type.WATER:
			return 'W'
		Type.LAVA:
			return 'L'
		Type.ICE:
			return 'I'
		Type.TELEPORTER:
			return 'T'
		Type.SWITCH:
			return '$'
		Type.DOOR:
			return 'D'
		Type.KEY:
			return 'K'
		Type.SPRING:
			return '^'
		Type.ARROW:
			return '>'
		Type.TRAP:
			return '!'
		Type.CHECKPOINT:
			return 'C'
		Type.COIN:
			return 'o'
		Type.GEM:
			return '*'
		_:
			return '.'

# Get display name for cell type
static func get_type_name(cell_type: Type) -> String:
	match cell_type:
		Type.EMPTY:
			return "Empty"
		Type.WALL:
			return "Wall"
		Type.HAZARD:
			return "Hazard"
		Type.GOAL:
			return "Goal"
		Type.START:
			return "Start"
		Type.WATER:
			return "Water"
		Type.LAVA:
			return "Lava"
		Type.ICE:
			return "Ice"
		Type.TELEPORTER:
			return "Teleporter"
		Type.SWITCH:
			return "Switch"
		Type.DOOR:
			return "Door"
		Type.KEY:
			return "Key"
		Type.SPRING:
			return "Spring"
		Type.ARROW:
			return "Arrow"
		Type.TRAP:
			return "Trap"
		Type.CHECKPOINT:
			return "Checkpoint"
		Type.COIN:
			return "Coin"
		Type.GEM:
			return "Gem"
		_:
			return "Unknown"
