extends Resource
class_name LevelData

## Level Information
@export var level_id: int = 1
@export var level_name: String = "Level 1"
@export var level_description: String = "Learn to move right"
@export var difficulty: int = 1  # 1-5 stars

## Grid Layout
@export var grid_width: int = 8
@export var grid_height: int = 6

## Level Layout (string array where each character represents a tile)
## Legend:
##   . = Empty floor
##   # = Wall
##   S = Start position
##   G = Goal
##   X = Hazard/death
@export_multiline var layout: String = """
########
#S.....#
#......#
#......#
#.....G#
########
"""

## Code Constraints (optional)
@export var max_commands: int = 0  # 0 = unlimited
@export var allowed_features: Array[String] = []  # Empty = all allowed
@export var starter_code: String = "# Write your code here\n"

## Hints
@export var hint_text: String = "Try using moveRight() to reach the goal!"

func get_layout_array() -> Array:
	"""Convert the layout string to a 2D array"""
	var lines = layout.strip_edges().split("\n")
	var result = []
	for line in lines:
		var row = []
		for i in range(line.length()):
			row.append(line[i])
		result.append(row)
	return result

func get_start_position() -> Vector2i:
	"""Find the start position in the layout"""
	var lines = layout.strip_edges().split("\n")
	for y in range(lines.size()):
		for x in range(lines[y].length()):
			if lines[y][x] == 'S':
				return Vector2i(x, y)
	return Vector2i(1, 1)  # Default

func get_goal_positions() -> Array[Vector2i]:
	"""Find all goal positions in the layout"""
	var goals: Array[Vector2i] = []
	var lines = layout.strip_edges().split("\n")
	for y in range(lines.size()):
		for x in range(lines[y].length()):
			if lines[y][x] == 'G':
				goals.append(Vector2i(x, y))
	return goals
