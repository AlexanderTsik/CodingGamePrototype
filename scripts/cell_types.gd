extends Node
class_name CellType

# Cell type definitions for the game grid
enum Type {
	EMPTY,      # Can walk through freely
	WALL,       # Blocks movement (player can't move into it)
	HAZARD,     # Player dies if they step on it (spikes, lava, etc.)
	GOAL,       # Completes the level when reached
	START       # Where player spawns
}

# Visual colors for each cell type
static func get_color(cell_type: Type) -> Color:
	match cell_type:
		Type.EMPTY:
			return Color(0.1, 0.1, 0.15, 1.0)  # Dark gray
		Type.WALL:
			return Color(0.15, 0.25, 0.45, 1.0)   # Brighter blue-gray
		Type.HAZARD:
			return Color(0.9, 0.1, 0.1, 1.0)   # Bright red
		Type.GOAL:
			return Color(0.1, 0.9, 0.1, 1.0)   # Bright green
		Type.START:
			return Color(0.95, 0.95, 0.3, 1.0)   # Bright yellow
		_:
			return Color(0.5, 0.5, 0.5, 1.0)   # Gray fallback

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
		_:
			return Type.EMPTY  # Default to empty
