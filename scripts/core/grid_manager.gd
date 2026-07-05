extends Node2D
class_name GridManager

signal level_completed
signal player_died
signal variant_advanced(current_variant: int, total_variants: int)
signal cell_activated(cell_pos: Vector2i, cell_type: CellType.Type)
signal item_collected(item_type: CellType.Type, position: Vector2i)
signal teleported(from_pos: Vector2i, to_pos: Vector2i)
signal grid_changed

@export var tile_size: int = 48

var grid: Array[Array] = []  # 2D array of CellType.Type
var cell_properties: Dictionary = {}  # Cell-specific data: {Vector2i: Dictionary}
var grid_width: int = 0
var grid_height: int = 0
var start_position: Vector2i = Vector2i(0, 0)
var goal_positions: Array[Vector2i] = []
var teleporter_pairs: Dictionary = {}  # {int id: [Vector2i pos1, Vector2i pos2]}
var active_variants: Array[String] = []
var current_variant_index: int = 0

func set_active_variants(variants: Array[String]) -> void:
	active_variants = variants.duplicate()
	current_variant_index = 0

func clear_active_variants() -> void:
	active_variants.clear()
	current_variant_index = 0

func has_active_variants() -> bool:
	return active_variants.size() > 0

func get_total_variants() -> int:
	return active_variants.size()

func get_current_variant_number() -> int:
	return current_variant_index + 1

func get_current_variant_layout() -> String:
	if has_active_variants() and current_variant_index >= 0 and current_variant_index < active_variants.size():
		return active_variants[current_variant_index]
	return ""

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
	
	Dbg.p("GridManager: Loaded level %dx%d, start at %v, %d goals, %d teleporter pairs" % 
		[grid_width, grid_height, start_position, goal_positions.size(), teleporter_pairs.size()])

func _pair_teleporters(positions: Array[Vector2i]):
	"""Pair teleporters in order of appearance"""
	for i in range(0, positions.size(), 2):
		if i + 1 < positions.size():
			var id = i >> 1
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
	return cell == CellType.Type.LAVA

func is_door(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a (closed) door"""
	return get_cell_at(grid_pos) == CellType.Type.DOOR

func is_key(grid_pos: Vector2i) -> bool:
	"""Check if this cell holds a key pickup"""
	return get_cell_at(grid_pos) == CellType.Type.KEY

func set_cell(grid_pos: Vector2i, cell_type: CellType.Type) -> void:
	"""Change a cell's type at runtime (e.g. picking up a key or opening a door)
	and notify listeners so the grid can redraw."""
	if not is_valid_position(grid_pos):
		return
	grid[grid_pos.y][grid_pos.x] = cell_type
	grid_changed.emit()

func is_goal(grid_pos: Vector2i) -> bool:
	"""Check if this cell is a goal"""
	return get_cell_at(grid_pos) == CellType.Type.GOAL

static func is_layout_solvable(layout: String) -> bool:
	"""BFS from the Start cell to any Goal. Walls block movement; hazards and
	teleporters are treated as passable (a conservative reachability check).

	Keys and doors are modelled faithfully: walking onto a KEY collects it, and a
	DOOR can only be crossed by spending a previously-collected key (which opens
	it permanently for that path). The search state therefore tracks which keys
	have been collected and which doors have been opened, so a goal locked behind
	a door is only reachable once the matching key is obtainable first.
	Returns false if there's no start, no goal, or no clear path."""
	var rows: Array[String] = []
	for line in layout.split("\n"):
		if line.strip_edges() != "":
			rows.append(line)
	if rows.is_empty():
		return false

	var start := Vector2i(-1, -1)
	var goals := {}
	var key_index := {}      # Vector2i -> bit index
	var door_index := {}     # Vector2i -> bit index
	for y in range(rows.size()):
		var line: String = rows[y]
		for x in range(line.length()):
			var p := Vector2i(x, y)
			match CellType.from_char(line[x]):
				CellType.Type.START: start = p
				CellType.Type.GOAL:  goals[p] = true
				CellType.Type.KEY:   key_index[p] = key_index.size()
				CellType.Type.DOOR:  door_index[p] = door_index.size()
	if start == Vector2i(-1, -1) or goals.is_empty():
		return false

	# BFS over state = (pos, collected-keys bitmask, opened-doors bitmask).
	var visited := {"%d,%d,0,0" % [start.x, start.y]: true}
	var queue: Array = [[start, 0, 0]]
	var dirs := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	while not queue.is_empty():
		var st = queue.pop_front()
		var cur: Vector2i = st[0]
		var keys_mask: int = st[1]
		var doors_mask: int = st[2]
		if goals.has(cur):
			return true
		for d in dirs:
			var nx: Vector2i = cur + d
			if nx.y < 0 or nx.y >= rows.size():
				continue
			var rline: String = rows[nx.y]
			if nx.x < 0 or nx.x >= rline.length():
				continue
			var ct = CellType.from_char(rline[nx.x])
			if ct == CellType.Type.WALL:
				continue
			var nkeys := keys_mask
			var ndoors := doors_mask
			if ct == CellType.Type.DOOR:
				var di: int = door_index[nx]
				if not (ndoors & (1 << di)):
					# Closed door — need a spare key (collected minus already spent).
					if _popcount(nkeys) - _popcount(ndoors) <= 0:
						continue
					ndoors |= (1 << di)
			elif ct == CellType.Type.KEY:
				nkeys |= (1 << int(key_index[nx]))
			var skey := "%d,%d,%d,%d" % [nx.x, nx.y, nkeys, ndoors]
			if visited.has(skey):
				continue
			visited[skey] = true
			queue.append([nx, nkeys, ndoors])
	return false

static func _popcount(n: int) -> int:
	var c := 0
	while n > 0:
		c += n & 1
		n >>= 1
	return c

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

func emit_teleported(from_pos: Vector2i, to_pos: Vector2i) -> void:
	"""Forward teleporter event emission through GridManager.
	Keeping emission in-class avoids UNUSED_SIGNAL warnings and centralizes the event."""
	teleported.emit(from_pos, to_pos)

func get_start_world_position() -> Vector2:
	"""Get world position (pixels) of start cell"""
	var half := float(tile_size) * 0.5
	return Vector2(start_position) * float(tile_size) + Vector2(half, half)

func world_to_grid(world_pos: Vector2) -> Vector2i:
	"""Convert world position to grid coordinates"""
	return Vector2i(world_pos / tile_size)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	"""Convert grid coordinates to world position (center of cell)"""
	var half := float(tile_size) * 0.5
	return Vector2(grid_pos) * float(tile_size) + Vector2(half, half)

func check_player_position(grid_pos: Vector2i):
	"""Check if player position triggers any events"""
	var cell_type = get_cell_at(grid_pos)
	
	# Check for hazards
	if is_hazard(grid_pos):
		player_died.emit()
		Dbg.p("GridManager: Player hit hazard!")
		return
	
	# Check for goal
	if is_goal(grid_pos):
		if has_active_variants() and current_variant_index < active_variants.size() - 1:
			current_variant_index += 1
			# Load the next variant's grid BEFORE signaling so listeners see
			# consistent state and the player can continue running on new grid.
			load_level_from_string(active_variants[current_variant_index])
			variant_advanced.emit(get_current_variant_number(), get_total_variants())
			Dbg.p("GridManager: Advanced to variant %d/%d" % [get_current_variant_number(), get_total_variants()])
			return
		level_completed.emit()
		Dbg.p("GridManager: Level completed!")
		return
	
	# Check for teleporter
	if cell_type == CellType.Type.TELEPORTER:
		cell_activated.emit(grid_pos, cell_type)
		Dbg.p("GridManager: Player entered teleporter at %v" % grid_pos)
	
