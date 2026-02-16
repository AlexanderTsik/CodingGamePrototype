extends Control

# Minimal test script to verify Godot basics work

func _ready():
	print("=== DIAGNOSTIC TEST STARTED ===")
	print("Godot version: ", Engine.get_version_info())
	print("Scene tree exists: ", get_tree() != null)
	
	# Test if classes are accessible
	print("\n=== Testing Class Accessibility ===")
	
	# Test GridManager
	var test_grid = GridManager.new()
	if test_grid:
		print("✓ GridManager accessible")
		test_grid.queue_free()
	else:
		print("❌ GridManager NOT accessible")
	
	# Test CellType
	var test_cell = CellType.Type.EMPTY
	print("✓ CellType accessible, EMPTY = ", test_cell)
	
	# Test DebugManager
	var test_debug = DebugManager.new()
	if test_debug:
		print("✓ DebugManager accessible")
		test_debug.queue_free()
	else:
		print("❌ DebugManager NOT accessible")
	
	# Test WatchManager
	var test_watch = WatchManager.new()
	if test_watch:
		print("✓ WatchManager accessible")
		test_watch.queue_free()
	else:
		print("❌ WatchManager NOT accessible")
	
	print("\n=== Testing Scene Paths ===")
	var scenes = [
		"res://scenes/ui/main_menu.tscn",
		"res://scenes/ui/level_select.tscn",
		"res://scenes/game/main.tscn",
		"res://scenes/game/player.tscn"
	]
	
	for scene_path in scenes:
		if ResourceLoader.exists(scene_path):
			print("✓ ", scene_path)
		else:
			print("❌ MISSING: ", scene_path)
	
	print("\n=== Testing Script Paths ===")
	var scripts = [
		"res://scripts/ui/main.gd",
		"res://scripts/core/grid_manager.gd",
		"res://scripts/core/player.gd",
		"res://scripts/levels/simple_grid.gd"
	]
	
	for script_path in scripts:
		if ResourceLoader.exists(script_path):
			print("✓ ", script_path)
		else:
			print("❌ MISSING: ", script_path)
	
	print("\n=== DIAGNOSTIC TEST COMPLETE ===")
	print("If you see this, basic Godot functionality works.")
	print("Check above for any ❌ errors.\n")
