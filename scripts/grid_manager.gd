extends Node2D
class_name GridManager

signal level_completed
signal player_died

@export var tile_size: int = 64

var grid: Array[Array] = []  # 2D array of CellType.Type
var grid_width: int = 0
var grid_height: int = 0
var start_position: Vector2i = Vector2i(0, 0)
var goal_positions: Array[Vector2i] = []

func load_level_from_string(layout: String):
	"""Parse ASCII art level layout into grid"""
	clear_grid()
	
	var lines = layout.split("\n")
	# Remove empty lines - PackedStringArray doesn't have filter in Godot 4.5
	var filtered_lines: Array[String] = []
	for line in lines:
		if line.strip_edges() != "":
			filtered_lines.append(line)
	
	if filtered_lines.size() == 0:
		push_error("GridManager: Empty level layout")
		return
	
	grid_height = filtered_lines.size()
	grid_width = filtered_lines[0].length()
	
	# Initialize grid
	grid.clear()
	goal_positions.clear()
	
	for y in range(grid_height):
		var row: Array = []
		var line = filtered_lines[y]
		
		for x in range(grid_width):
			var ch = line[x] if x < line.length() else ' '
			var cell_type = CellType.from_char(ch)
			row.append(cell_type)
			
			# Track special positions
			if cell_type == CellType.Type.START:
				start_position = Vector2i(x, y)
			elif cell_type == CellType.Type.GOAL:
				goal_positions.append(Vector2i(x, y))
		
		grid.append(row)
	
	print("GridManager: Loaded level %dx%d, start at %v, %d goals" % [grid_width, grid_height, start_position, goal_positions.size()])

func clear_grid():
	"""Clear the current grid"""
	grid.clear()
	goal_positions.clear()
	grid_width = 0
	grid_height = 0

func get_cell_at(grid_pos: Vector2i) -> CellType.Type:
	"""Get the cell type at a grid position"""
	if not is_valid_position(grid_pos):
		return CellType.Type.WALL  # Out of bounds = wall
	
	return grid[grid_pos.y][grid_pos.x]

func is_valid_position(grid_pos: Vector2i) -> bool:
	"""Check if position is within grid bounds"""
	return (grid_pos.x >= 0 and grid_pos.x < grid_width and 
			grid_pos.y >= 0 and grid_pos.y < grid_height)

func is_walkable(grid_pos: Vector2i) -> bool:
	"""Check if player can walk into this cell"""
	var cell = get_cell_at(grid_pos)
	return cell != CellType.Type.WALL

func is_hazard(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a hazard"""
	return get_cell_at(grid_pos) == CellType.Type.HAZARD

func is_goal(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a goal"""
	return get_cell_at(grid_pos) == CellType.Type.GOAL

func get_start_world_position() -> Vector2:
	"""Get world position (pixels) of start cell"""
	return Vector2(start_position) * tile_size + Vector2(tile_size / 2, tile_size / 2)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	"""Convert world position to grid coordinates"""
	return Vector2i(world_pos / tile_size)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	"""Convert grid coordinates to world position (center of cell)"""
	return Vector2(grid_pos) * tile_size + Vector2(tile_size / 2, tile_size / 2)

func check_player_position(grid_pos: Vector2i):
	"""Check if player position triggers any events"""
	if is_hazard(grid_pos):
		player_died.emit()
		print("GridManager: Player hit hazard!")
	elif is_goal(grid_pos):
		level_completed.emit()
		print("GridManager: Level completed!")
