extends CharacterBody2D

# Note: GridManager is auto-loaded via class_name

const SPRITE_NATURAL_SIZE := 32.0  # uploaded ladybug frames are 32 px at scale 1.0

var start_position: Vector2
var grid_position: Vector2i
var current_direction: Vector2i = Vector2i(0, -1)
var inventory: Array[String] = []
var move_count: int = 0

@export var grid_manager: GridManager

var _last_tile_size: int = 0

signal movement_started
signal movement_completed
signal hit_wall
signal reached_goal
signal hit_hazard
signal item_collected(item_name: String)
signal teleported(from_pos: Vector2i, to_pos: Vector2i)

func _ready():
	start_position = position
	if grid_manager:
		grid_position = Vector2i(position / grid_manager.tile_size)
	_update_facing_rotation()
	_set_crawling(false)


func _set_crawling(active: bool) -> void:
	"""Crawl animation runs only while the bug is actually moving; otherwise it
	rests on a single static frame so it sits idle instead of animating forever."""
	var animated_sprite := get_node_or_null("Sprite")
	if animated_sprite is AnimatedSprite2D:
		var anim := animated_sprite as AnimatedSprite2D
		if active:
			anim.play("crawl")
		else:
			anim.stop()
			anim.frame = 0

func _process(_delta: float):
	if grid_manager and grid_manager.tile_size != _last_tile_size:
		_last_tile_size = grid_manager.tile_size
		_sync_sprite_and_position()

func reset_position():
	if grid_manager:
		position = grid_manager.get_start_world_position()
		grid_position = grid_manager.start_position
	else:
		position = start_position
		grid_position = Vector2i(position / max(grid_manager.tile_size if grid_manager else 48, 1))
	current_direction = Vector2i(0, -1)
	move_count = 0
	inventory.clear()
	_update_facing_rotation()
	_set_crawling(false)

func _sync_sprite_and_position():
	"""Called whenever tile_size changes — rescale sprite and snap position."""
	var ts := grid_manager.tile_size
	var sprite = get_node_or_null("Sprite")
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
	if sprite:
		var s := ts / SPRITE_NATURAL_SIZE
		sprite.scale = Vector2(s, s)
	# Snap position to correct world coords for current grid_position
	position = grid_manager.grid_to_world(grid_position)

func move(duration: float = 0.25) -> void:
	"""Move one cell forward in the current facing direction."""
	await _attempt_move(current_direction, duration)

func turnRight():
	"""Turn 90 degrees clockwise"""
	# Rotate direction vector 90 degrees clockwise
	# (x, y) -> (y, -x)
	var new_x = -current_direction.y
	var new_y = current_direction.x
	current_direction = Vector2i(new_x, new_y)
	_update_facing_rotation()
	Dbg.p("Turned right, now facing: %v" % current_direction)

func turnLeft():
	"""Turn 90 degrees counter-clockwise"""
	# Rotate direction vector 90 degrees counter-clockwise
	# (x, y) -> (-y, x)
	var new_x = current_direction.y
	var new_y = -current_direction.x
	current_direction = Vector2i(new_x, new_y)
	_update_facing_rotation()
	Dbg.p("Turned left, now facing: %v" % current_direction)

func turnBack():
	"""Turn 180 degrees around"""
	current_direction = -current_direction
	_update_facing_rotation()
	Dbg.p("Turned around, now facing: %v" % current_direction)

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
func has_key() -> bool:
	"""True if the bug is currently carrying at least one key."""
	return inventory.has("key")

func _can_enter(pos: Vector2i) -> bool:
	"""Whether the bug could step into `pos` right now. Hazards block; a locked
	door counts as passable only while we hold a key (we'd spend it to open it)."""
	if not grid_manager:
		return true
	if grid_manager.is_hazard(pos):
		return false
	if grid_manager.is_door(pos):
		return has_key()
	return grid_manager.is_walkable(pos)

func is_front_clear() -> bool:
	if not grid_manager:
		return true
	var check_pos = grid_position + current_direction
	var result = _can_enter(check_pos)
	Dbg.p("frontIsClear() - Facing: %v, Checking: %v, Result: %s" % [current_direction, check_pos, result])
	return result

func is_left_clear() -> bool:
	if not grid_manager:
		return true
	# Rotate 90° counter-clockwise: (x, y) -> (y, -x)
	var left_dir = Vector2i(current_direction.y, -current_direction.x)
	return _can_enter(grid_position + left_dir)

func is_right_clear() -> bool:
	if not grid_manager:
		return true
	# Rotate 90° clockwise: (x, y) -> (-y, x)
	var right_dir = Vector2i(-current_direction.y, current_direction.x)
	return _can_enter(grid_position + right_dir)

func is_on_goal() -> bool:
	if not grid_manager:
		return false
	return grid_manager.is_goal(grid_position)

func is_on_hazard() -> bool:
	if not grid_manager:
		return false
	return grid_manager.is_hazard(grid_position)

func _attempt_move(direction: Vector2i, duration: float) -> void:
	"""Attempt to move in a direction with collision checking."""
	var target_grid_pos = grid_position + direction
	
	if not grid_manager:
		# No grid loaded — there's nothing to collide with, so just move.
		grid_position = target_grid_pos
		await _do_move(direction, duration)
		return
	
	# Locked door: spend a key to open it, otherwise it blocks like a wall.
	if grid_manager.is_door(target_grid_pos):
		if has_key():
			inventory.erase("key")
			grid_manager.set_cell(target_grid_pos, CellType.Type.EMPTY)
			Dbg.p("Opened door at %v" % target_grid_pos)
		else:
			hit_wall.emit()
			Dbg.p("Door locked at %v (no key)" % target_grid_pos)
			return
	elif not grid_manager.is_walkable(target_grid_pos):
		hit_wall.emit()
		Dbg.p("Hit wall at %v" % target_grid_pos)
		return

	# Move is valid, execute it
	move_count += 1
	grid_position = target_grid_pos
	await _do_move(direction, duration)
	
	# Pick up a key when landing on it.
	if grid_manager.is_key(grid_position):
		inventory.append("key")
		grid_manager.set_cell(grid_position, CellType.Type.EMPTY)
		item_collected.emit("key")
		Dbg.p("Picked up key at %v" % grid_position)
	
	# Check if player landed on teleporter
	if grid_manager.is_teleporter(grid_position):
		await _handle_teleporter()
	else:
		if grid_manager.is_hazard(grid_position):
			hit_hazard.emit()
		elif grid_manager.is_goal(grid_position):
			reached_goal.emit()
		grid_manager.check_player_position(grid_position)

func _do_move(direction: Vector2i, duration: float) -> void:
	"""Animate the move over `duration` seconds (0 = instant), then wait for it."""
	movement_started.emit()
	var ts := grid_manager.tile_size if grid_manager else 48
	var target_pos := position + Vector2(direction * ts)
	if duration <= 0.0:
		position = target_pos
	else:
		_set_crawling(true)
		var tween := create_tween()
		tween.tween_property(self, "position", target_pos, duration)
		await tween.finished
		_set_crawling(false)
	movement_completed.emit()

func _handle_teleporter():
	"""Handle teleporter logic"""
	var from_pos = grid_position
	var target_pos = grid_manager.get_teleporter_target(from_pos)
	
	if target_pos != from_pos:
		Dbg.p("Player: Teleporting from %v to %v" % [from_pos, target_pos])
		
		# Emit signal
		teleported.emit(from_pos, target_pos)
		grid_manager.emit_teleported(from_pos, target_pos)
		
		# Teleport player
		grid_position = target_pos
		position = grid_manager.grid_to_world(target_pos)
		
		# Check new position
		await get_tree().create_timer(0.1).timeout
		if grid_manager.is_hazard(grid_position):
			hit_hazard.emit()
		elif grid_manager.is_goal(grid_position):
			reached_goal.emit()
		grid_manager.check_player_position(grid_position)


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
		Dbg.p("Player: Collected %s" % item_name)

func use_item(item_name: String) -> bool:
	if item_name in inventory:
		inventory.erase(item_name)
		Dbg.p("Player: Used %s" % item_name)
		return true
	return false

func clear_inventory():
	inventory.clear()
