@tool
extends EditorScript

# Run this script in Godot Editor (File > Run) to generate level resource files

func _run():
	var level_defs = preload("res://scripts/level_definitions.gd").new()
	
	for level_def in level_defs.all_levels:
		create_level_resource(level_def)
	
	print("All levels generated successfully!")

func create_level_resource(level_def: Dictionary):
	var level = LevelData.new()
	
	level.level_id = level_def.level_id
	level.level_name = level_def.level_name
	level.level_description = level_def.level_description
	level.difficulty = level_def.difficulty
	level.grid_width = level_def.grid_width
	level.grid_height = level_def.grid_height
	level.layout = level_def.layout
	level.starter_code = level_def.get("starter_code", "")
	level.hint_text = level_def.get("hint_text", "")
	
	var filename = "res://resources/levels/level_%02d.tres" % level.level_id
	var result = ResourceSaver.save(level, filename)
	
	if result == OK:
		print("Created: " + filename)
	else:
		push_error("Failed to create: " + filename)
