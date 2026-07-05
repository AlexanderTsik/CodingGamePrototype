extends Node
class_name CellType

# Cell type definitions for the game grid.
# The game intentionally uses a small, focused set of mechanics:
#   EMPTY / WALL  — basic movement and collision
#   START / GOAL  — where a run begins and ends
#   LAVA          — deadly cell; sensors report it as blocked, stepping on it ends the run
#   TELEPORTER    — transports the player to its paired teleporter
#   DOOR / KEY    — doors block until a collected key is spent to open them
enum Type {
	EMPTY,       # Can walk through freely
	WALL,        # Blocks movement (player can't move into it)
	GOAL,        # Completes the level when reached
	START,       # Where player spawns
	LAVA,        # Instant death when stepped on; sensors treat it like a wall
	TELEPORTER,  # Transport to paired teleporter
	DOOR,        # Locked; walking into it spends one key to open it
	KEY          # Pickup to unlock doors
}

# Visual colors for each cell type
static func get_color(cell_type: Type) -> Color:
	match cell_type:
		Type.EMPTY:
			return Color(0.54, 0.56, 0.60, 1.0)
		Type.WALL:
			return Color(0.22, 0.26, 0.35, 1.0)
		Type.GOAL:
			return Color(0.08, 0.58, 0.28, 1.0)
		Type.START:
			return Color(0.85, 0.68, 0.08, 1.0)
		Type.LAVA:
			return Color(0.85, 0.28, 0.04, 1.0)
		Type.TELEPORTER:
			return Color(0.55, 0.08, 0.75, 1.0)
		Type.DOOR:
			return Color(0.48, 0.30, 0.14, 1.0)
		Type.KEY:
			return Color(0.92, 0.75, 0.05, 1.0)
		_:
			return Color(0.4, 0.4, 0.4, 1.0)

# Emoji icon for each cell type (displayed in the center of the cell)
static func get_emoji(cell_type: Type) -> String:
	match cell_type:
		Type.WALL:
			return "🧱"
		Type.GOAL:
			return "🏁"
		Type.START:
			return "🐞"
		Type.LAVA:
			return "🔥"
		Type.TELEPORTER:
			return "🌀"
		Type.DOOR:
			return "🚪"
		Type.KEY:
			return "🔑"
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
		'L':
			return Type.LAVA
		'T':
			return Type.TELEPORTER
		'D':
			return Type.DOOR
		'K':
			return Type.KEY
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
		Type.LAVA:
			return 'L'
		Type.TELEPORTER:
			return 'T'
		Type.DOOR:
			return 'D'
		Type.KEY:
			return 'K'
		_:
			return '.'

# Get display name for cell type
static func get_type_name(cell_type: Type) -> String:
	match cell_type:
		Type.EMPTY:
			return "Empty"
		Type.WALL:
			return "Wall"
		Type.GOAL:
			return "Goal"
		Type.START:
			return "Start"
		Type.LAVA:
			return "Lava"
		Type.TELEPORTER:
			return "Teleporter"
		Type.DOOR:
			return "Door"
		Type.KEY:
			return "Key"
		_:
			return "Unknown"
