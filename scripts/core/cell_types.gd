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
			return Color(0.08, 0.09, 0.12, 1.0)
		Type.WALL:
			return Color(0.22, 0.26, 0.35, 1.0)
		Type.HAZARD:
			return Color(0.72, 0.12, 0.12, 1.0)
		Type.GOAL:
			return Color(0.08, 0.58, 0.28, 1.0)
		Type.START:
			return Color(0.85, 0.68, 0.08, 1.0)
		Type.WATER:
			return Color(0.12, 0.35, 0.78, 1.0)
		Type.LAVA:
			return Color(0.85, 0.28, 0.04, 1.0)
		Type.ICE:
			return Color(0.55, 0.78, 0.95, 1.0)
		Type.TELEPORTER:
			return Color(0.55, 0.08, 0.75, 1.0)
		Type.SWITCH:
			return Color(0.82, 0.82, 0.08, 1.0)
		Type.DOOR:
			return Color(0.48, 0.30, 0.14, 1.0)
		Type.KEY:
			return Color(0.92, 0.75, 0.05, 1.0)
		Type.SPRING:
			return Color(0.18, 0.75, 0.35, 1.0)
		Type.ARROW:
			return Color(0.05, 0.68, 0.72, 1.0)
		Type.TRAP:
			return Color(0.58, 0.08, 0.08, 1.0)
		Type.CHECKPOINT:
			return Color(0.18, 0.65, 0.42, 1.0)
		Type.COIN:
			return Color(0.95, 0.82, 0.12, 1.0)
		Type.GEM:
			return Color(0.42, 0.05, 0.82, 1.0)
		_:
			return Color(0.4, 0.4, 0.4, 1.0)

# Emoji icon for each cell type (displayed in the center of the cell)
static func get_emoji(cell_type: Type) -> String:
	match cell_type:
		Type.WALL:
			return "🧱"
		Type.HAZARD:
			return "💀"
		Type.GOAL:
			return "🏁"
		Type.START:
			return "🐞"
		Type.WATER:
			return "💧"
		Type.LAVA:
			return "🔥"
		Type.ICE:
			return "🧊"
		Type.TELEPORTER:
			return "🌀"
		Type.SWITCH:
			return "🔘"
		Type.DOOR:
			return "🚪"
		Type.KEY:
			return "🔑"
		Type.SPRING:
			return "🔼"
		Type.ARROW:
			return "➡"
		Type.TRAP:
			return "⚠"
		Type.CHECKPOINT:
			return "✅"
		Type.COIN:
			return "🪙"
		Type.GEM:
			return "💎"
		_:
			return ""

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
