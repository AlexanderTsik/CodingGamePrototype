extends CharacterBody2D

# Note: GridManager is auto-loaded via class_name

const GRID_SIZE = 64
var start_position: Vector2
var grid_position: Vector2i  # Current grid coordinates
var current_direction: Vector2i = Vector2i(0, -1)  # Facing up by default
var inventory: Array[String] = []  # Player's collected items

# Reference to grid manager
@export var grid_manager: GridManager

signal movement_started
signal movement_completed
signal hit_wall
signal reached_goal
signal hit_hazard
signal item_collected(item_name: String)
signal teleported(from_pos: Vector2i, to_pos: Vector2i)

func _ready():
	start_position = position
	grid_position = Vector2i(position / GRID_SIZE)
	_update_facing_rotation()

func reset_position():
	if grid_manager:
		position = grid_manager.get_start_world_position()
		grid_position = grid_manager.start_position
	else:
		position = start_position
		grid_position = Vector2i(position / GRID_SIZE)
	current_direction = Vector2i(0, -1)  # Reset to face up
	_update_facing_rotation()

func move():
	"""Move one cell forward in the current facing direction"""
	_attempt_move(current_direction)

func turnRight():
	"""Turn 90 degrees clockwise"""
	# Rotate direction vector 90 degrees clockwise
	# (x, y) -> (y, -x)
	var new_x = -current_direction.y
	var new_y = current_direction.x
	current_direction = Vector2i(new_x, new_y)
	_update_facing_rotation()
	print("Turned right, now facing: %v" % current_direction)

func turnLeft():
	"""Turn 90 degrees counter-clockwise"""
	# Rotate direction vector 90 degrees counter-clockwise
	# (x, y) -> (-y, x)
	var new_x = current_direction.y
	var new_y = -current_direction.x
	current_direction = Vector2i(new_x, new_y)
	_update_facing_rotation()
	print("Turned left, now facing: %v" % current_direction)

func turnBack():
	"""Turn 180 degrees around"""
	current_direction = -current_direction
	_update_facing_rotation()
	print("Turned around, now facing: %v" % current_direction)

func _update_facing_rotation():
	"""Rotate sprite to face current direction"""
	# Get sprite node
	var sprite = get_node_or_null("Sprite")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = get_node_or_null("ColorRect")
	
	if sprite:
		# Calculate rotation based on direction (sprite faces up at 0°)
		if current_direction == Vector2i(0, -1):  # Up
			sprite.rotation = 0
		elif current_direction == Vector2i(1, 0):  # Right
			sprite.rotation = PI/2
		elif current_direction == Vector2i(0, 1):  # Down
			sprite.rotation = PI
		elif current_direction == Vector2i(-1, 0):  # Left
			sprite.rotation = -PI/2

# Environment checking functions
func is_front_clear() -> bool:
	if not grid_manager:
		return true
	var check_pos = grid_position + current_direction
	var result = grid_manager.is_walkable(check_pos)
	print("frontIsClear() - Facing: %v, Checking: %v, Result: %s" % [current_direction, check_pos, result])
	return result

func is_left_clear() -> bool:
	if not grid_manager:
		return true
	# Rotate 90° counter-clockwise: (x, y) -> (y, -x)
	var left_dir = Vector2i(current_direction.y, -current_direction.x)
	var check_pos = grid_position + left_dir
	return grid_manager.is_walkable(check_pos)

func is_right_clear() -> bool:
	if not grid_manager:
		return true
	# Rotate 90° clockwise: (x, y) -> (-y, x)
	var right_dir = Vector2i(-current_direction.y, current_direction.x)
	var check_pos = grid_position + right_dir
	return grid_manager.is_walkable(check_pos)

func is_on_goal() -> bool:
	if not grid_manager:
		return false
	return grid_manager.is_goal(grid_position)

func is_on_hazard() -> bool:
	if not grid_manager:
		return false
	return grid_manager.is_hazard(grid_position)

func _attempt_move(direction: Vector2i):
	"""Attempt to move in a direction with collision checking"""
	var target_grid_pos = grid_position + direction
	
	if not grid_manager:
		# Fallback to simple boundary checking
		if target_grid_pos.x < 0 or target_grid_pos.x >= 8 or target_grid_pos.y < 0 or target_grid_pos.y >= 10:
			hit_wall.emit()
			print("Hit boundary!")
			return
		grid_position = target_grid_pos
		_do_move(direction)
		return
	
	# Check if walkable
	if not grid_manager.is_walkable(target_grid_pos):
		hit_wall.emit()
		print("Hit wall at", target_grid_pos)
		return
	
	# Move is valid, execute it
	grid_position = target_grid_pos
	_do_move(direction)
	
	# Check for hazards and goals after move completes
	await _wait_for_tween()
	
	# Check if player landed on teleporter
	if grid_manager.is_teleporter(grid_position):
		await _handle_teleporter()
	else:
		grid_manager.check_player_position(grid_position)

func _do_move(direction: Vector2i):
	"""Execute the actual movement animation"""
	movement_started.emit()
	var tween = create_tween()
	var target_pos = position + Vector2(direction * GRID_SIZE)
	tween.tween_property(self, "position", target_pos, 0.25)
	tween.finished.connect(_on_movement_finished)

func _on_movement_finished():
	movement_completed.emit()

func _wait_for_tween():
	"""Helper to wait for tween to complete"""
	await get_tree().create_timer(0.26).timeout

func _handle_teleporter():
	"""Handle teleporter logic"""
	var from_pos = grid_position
	var target_pos = grid_manager.get_teleporter_target(from_pos)
	
	if target_pos != from_pos:
		print("Player: Teleporting from %v to %v" % [from_pos, target_pos])
		
		# Emit signal
		teleported.emit(from_pos, target_pos)
		grid_manager.teleported.emit(from_pos, target_pos)
		
		# Teleport player
		grid_position = target_pos
		position = grid_manager.grid_to_world(target_pos)
		
		# Check new position
		await get_tree().create_timer(0.1).timeout
		grid_manager.check_player_position(grid_position)

# New sensor functions for cell types
func is_on_water() -> bool:
	if not grid_manager:
		return false
	return grid_manager.get_cell_at(grid_position) == CellType.Type.WATER

func is_on_ice() -> bool:
	if not grid_manager:
		return false
	return grid_manager.get_cell_at(grid_position) == CellType.Type.ICE

func is_on_teleporter() -> bool:
	if not grid_manager:
		return false
	return grid_manager.get_cell_at(grid_position) == CellType.Type.TELEPORTER

func get_cell_type() -> String:
	if not grid_manager:
		return "EMPTY"
	var cell = grid_manager.get_cell_at(grid_position)
	return CellType.Type.keys()[cell]

# Inventory functions
func has_item(item_name: String) -> bool:
	return item_name in inventory

func add_item(item_name: String):
	if not item_name in inventory:
		inventory.append(item_name)
		item_collected.emit(item_name)
		print("Player: Collected %s" % item_name)

func use_item(item_name: String) -> bool:
	if item_name in inventory:
		inventory.erase(item_name)
		print("Player: Used %s" % item_name)
		return true
	return false

func clear_inventory():
	inventory.clear()
