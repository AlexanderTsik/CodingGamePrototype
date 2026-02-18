extends Node2D
class_name GridManager

signal level_completed
signal player_died
signal cell_activated(cell_pos: Vector2i, cell_type: CellType.Type)
signal item_collected(item_type: CellType.Type, position: Vector2i)
signal teleported(from_pos: Vector2i, to_pos: Vector2i)

@export var tile_size: int = 64

var grid: Array[Array] = []  # 2D array of CellType.Type
var cell_properties: Dictionary = {}  # Cell-specific data: {Vector2i: Dictionary}
var grid_width: int = 0
var grid_height: int = 0
var start_position: Vector2i = Vector2i(0, 0)
var goal_positions: Array[Vector2i] = []
var teleporter_pairs: Dictionary = {}  # {int id: [Vector2i pos1, Vector2i pos2]}

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
	teleporter_pairs.clear()
	cell_properties.clear()
	
	# Track teleporters for pairing
	var teleporter_positions: Array[Vector2i] = []
	
	for y in range(grid_height):
		var row: Array = []
		var line = filtered_lines[y]
		
		for x in range(grid_width):
			var ch = line[x] if x < line.length() else ' '
			var cell_type = CellType.from_char(ch)
			row.append(cell_type)
			
			var pos = Vector2i(x, y)
			
			# Track special positions
			if cell_type == CellType.Type.START:
				start_position = pos
			elif cell_type == CellType.Type.GOAL:
				goal_positions.append(pos)
			elif cell_type == CellType.Type.TELEPORTER:
				teleporter_positions.append(pos)
		
		grid.append(row)
	
	# Pair teleporters (first with second, third with fourth, etc.)
	_pair_teleporters(teleporter_positions)
	
	print("GridManager: Loaded level %dx%d, start at %v, %d goals, %d teleporter pairs" % 
		[grid_width, grid_height, start_position, goal_positions.size(), teleporter_pairs.size()])

func _pair_teleporters(positions: Array[Vector2i]):
	"""Pair teleporters in order of appearance"""
	for i in range(0, positions.size(), 2):
		if i + 1 < positions.size():
			var id = i / 2
			teleporter_pairs[id] = [positions[i], positions[i + 1]]
			
			# Store properties for each teleporter
			set_cell_property(positions[i], "teleporter_id", id)
			set_cell_property(positions[i], "target_pos", positions[i + 1])
			set_cell_property(positions[i + 1], "teleporter_id", id)
			set_cell_property(positions[i + 1], "target_pos", positions[i])
		else:
			push_warning("GridManager: Unpaired teleporter at %v" % positions[i])

func clear_grid():
	"""Clear the current grid"""
	grid.clear()
	goal_positions.clear()
	teleporter_pairs.clear()
	cell_properties.clear()
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
	# Walls and doors block movement
	return cell != CellType.Type.WALL and cell != CellType.Type.DOOR

func is_hazard(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a hazard"""
	var cell = get_cell_at(grid_pos)
	return cell == CellType.Type.HAZARD or cell == CellType.Type.LAVA

func is_goal(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a goal"""
	return get_cell_at(grid_pos) == CellType.Type.GOAL

# Cell property methods
func set_cell_property(pos: Vector2i, key: String, value):
	"""Set a property for a specific cell"""
	if not cell_properties.has(pos):
		cell_properties[pos] = {}
	cell_properties[pos][key] = value

func get_cell_property(pos: Vector2i, key: String, default = null):
	"""Get a property for a specific cell"""
	if cell_properties.has(pos) and cell_properties[pos].has(key):
		return cell_properties[pos][key]
	return default

func has_cell_property(pos: Vector2i, key: String) -> bool:
	"""Check if cell has a specific property"""
	return cell_properties.has(pos) and cell_properties[pos].has(key)

# Teleporter methods
func get_teleporter_target(pos: Vector2i) -> Vector2i:
	"""Get the target position for a teleporter"""
	return get_cell_property(pos, "target_pos", pos)

func is_teleporter(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a teleporter"""
	return get_cell_at(grid_pos) == CellType.Type.TELEPORTER

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
	var cell_type = get_cell_at(grid_pos)
	
	# Check for hazards
	if is_hazard(grid_pos):
		player_died.emit()
		print("GridManager: Player hit hazard!")
		return
	
	# Check for goal
	if is_goal(grid_pos):
		level_completed.emit()
		print("GridManager: Level completed!")
		return
	
	# Check for teleporter
	if cell_type == CellType.Type.TELEPORTER:
		cell_activated.emit(grid_pos, cell_type)
		print("GridManager: Player entered teleporter at %v" % grid_pos)
	
	# Check for collectibles
	elif cell_type == CellType.Type.KEY or cell_type == CellType.Type.COIN or cell_type == CellType.Type.GEM:
		item_collected.emit(cell_type, grid_pos)
		var type_name = CellType.Type.keys()[cell_type]
		print("GridManager: Player collected %s at %v" % [type_name, grid_pos])
	
	# Check for switches
	elif cell_type == CellType.Type.SWITCH:
		cell_activated.emit(grid_pos, cell_type)
		print("GridManager: Player activated switch at %v" % grid_pos)
