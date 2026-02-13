extends Node
# GameManager - Singleton for managing game state
# Access via GameManager singleton (AutoLoad)

## Singleton pattern
static var instance: GameManager

## Current game state
var current_level_id: int = 1
var completed_levels: Array[int] = []
var is_playing: bool = false

## References
var current_level_data: LevelData
var player_ref: CharacterBody2D
var level_manager_ref: LevelManager

signal level_started(level_id: int)
signal level_won
signal level_failed(reason: String)
signal game_paused
signal game_resumed

func _ready():
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	
	# Don't auto-pause
	process_mode = Node.PROCESS_MODE_ALWAYS

func load_level(level_id: int):
	"""Load a specific level"""
	current_level_id = level_id
	var level_path = "res://resources/levels/level_%02d.tres" % level_id
	
	if ResourceLoader.exists(level_path):
		current_level_data = load(level_path)
		level_started.emit(level_id)
	else:
		push_error("Level not found: " + level_path)

func start_level():
	"""Start/restart the current level"""
	is_playing = true

func complete_level():
	"""Mark current level as completed"""
	if not current_level_id in completed_levels:
		completed_levels.append(current_level_id)
	
	is_playing = false
	level_won.emit()

func fail_level(reason: String = ""):
	"""Handle level failure"""
	is_playing = false
	level_failed.emit(reason)

func is_level_unlocked(level_id: int) -> bool:
	"""Check if a level is unlocked"""
	if level_id == 1:
		return true
	return (level_id - 1) in completed_levels

func get_next_level_id() -> int:
	"""Get the next level to play"""
	return current_level_id + 1

func has_next_level() -> bool:
	"""Check if there's a next level"""
	var next_path = "res://resources/levels/level_%02d.tres" % get_next_level_id()
	return ResourceLoader.exists(next_path)

func pause_game():
	get_tree().paused = true
	game_paused.emit()

func resume_game():
	get_tree().paused = false
	game_resumed.emit()

func reset_progress():
	"""Reset all progress (for testing)"""
	completed_levels.clear()
	current_level_id = 1

func save_progress():
	"""Save progress to file"""
	var save_data = {
		"completed_levels": completed_levels,
		"current_level": current_level_id
	}
	
	var file = FileAccess.open("user://progress.save", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_progress():
	"""Load progress from file"""
	if not FileAccess.file_exists("user://progress.save"):
		return
	
	var file = FileAccess.open("user://progress.save", FileAccess.READ)
	if file:
		var save_data = file.get_var()
		file.close()
		
		if save_data:
			completed_levels = save_data.get("completed_levels", [])
			current_level_id = save_data.get("current_level", 1)
