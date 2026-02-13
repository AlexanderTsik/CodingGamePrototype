extends CharacterBody2D

const GRID_SIZE = 64
var start_position: Vector2
var grid_position: Vector2i  # Current grid coordinates

@export var level_manager: LevelManager

signal movement_started
signal movement_completed
signal hit_wall
signal reached_goal
signal hit_hazard

func _ready():
	start_position = position
	if level_manager:
		grid_position = level_manager.world_to_grid(position)

func reset_position():
	if level_manager:
		position = level_manager.get_start_world_position()
		grid_position = level_manager.start_pos
	else:
		position = start_position
		grid_position = Vector2i(position / GRID_SIZE)

func move_right():
	_attempt_move(Vector2i(1, 0))

func move_left():
	_attempt_move(Vector2i(-1, 0))

func move_up():
	_attempt_move(Vector2i(0, -1))

func move_down():
	_attempt_move(Vector2i(0, 1))

func _attempt_move(direction: Vector2i):
	"""Attempt to move in a direction with collision detection"""
	var target_grid_pos = grid_position + direction
	
	# Check if we have a level manager
	if not level_manager:
		# Fallback to old behavior
		_do_move(direction)
		return
	
	# Check if target position is valid
	if not level_manager.is_valid_position(target_grid_pos):
		hit_wall.emit()
		return
	
	# Check if target is walkable
	if not level_manager.is_walkable(target_grid_pos):
		hit_wall.emit()
		return
	
	# Move is valid, execute it
	grid_position = target_grid_pos
	_do_move(direction)
	
	# Check for hazards and goals after move completes
	await _wait_for_tween()
	level_manager.check_player_position(grid_position)

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
