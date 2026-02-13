extends Control

func _ready():
	# Connect back button
	$MarginContainer/VBoxContainer/ButtonContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Load and display custom levels
	_load_custom_levels()

func _load_custom_levels():
	"""Load all custom levels from user data folder"""
	var grid = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
	var custom_levels_path = "user://custom_levels/"
	
	# Check if directory exists
	if not DirAccess.dir_exists_absolute(custom_levels_path):
		# Show message that no custom levels exist
		var label = Label.new()
		label.text = "No custom levels found.\nCreate one in the Level Editor!"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		grid.add_child(label)
		return
	
	# Get all .json files in custom levels folder
	var dir = DirAccess.open(custom_levels_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var level_count = 0
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				_create_level_button(custom_levels_path + file_name)
				level_count += 1
			file_name = dir.get_next()
		
		dir.list_dir_end()
		
		if level_count == 0:
			var label = Label.new()
			label.text = "No custom levels found.\nCreate one in the Level Editor!"
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.add_theme_font_size_override("font_size", 20)
			grid.add_child(label)

func _create_level_button(file_path: String):
	"""Create a button for a custom level"""
	# Load level data
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		return
	
	var level_data = json.data
	var level_name = level_data.get("level_name", "Untitled")
	var created_date = level_data.get("created_date", "Unknown")
	
	# Create button container
	var container = VBoxContainer.new()
	container.custom_minimum_size = Vector2(200, 180)
	
	# Play button
	var play_button = Button.new()
	play_button.text = "▶ Play"
	play_button.custom_minimum_size = Vector2(0, 60)
	play_button.add_theme_font_size_override("font_size", 18)
	play_button.pressed.connect(_on_play_pressed.bind(level_data))
	
	# Edit button
	var edit_button = Button.new()
	edit_button.text = "✎ Edit"
	edit_button.custom_minimum_size = Vector2(0, 40)
	edit_button.add_theme_font_size_override("font_size", 14)
	edit_button.pressed.connect(_on_edit_pressed.bind(file_path))
	
	# Delete button
	var delete_button = Button.new()
	delete_button.text = "🗑 Delete"
	delete_button.custom_minimum_size = Vector2(0, 40)
	delete_button.add_theme_font_size_override("font_size", 14)
	delete_button.modulate = Color(1.0, 0.5, 0.5)
	delete_button.pressed.connect(_on_delete_pressed.bind(file_path))
	
	# Level info label
	var info_label = Label.new()
	info_label.text = level_name + "\n" + created_date.split("T")[0]
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 12)
	
	# Add to container
	container.add_child(info_label)
	container.add_child(play_button)
	container.add_child(edit_button)
	container.add_child(delete_button)
	
	# Add to grid
	var grid = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
	grid.add_child(container)

func _on_play_pressed(level_data: Dictionary):
	"""Play the selected custom level"""
	# Add level_id for custom levels
	level_data["level_id"] = 999
	get_tree().root.set_meta("custom_level", level_data)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_edit_pressed(file_path: String):
	"""Edit the selected custom level"""
	# Store file path for editor to load
	get_tree().root.set_meta("edit_level_path", file_path)
	get_tree().change_scene_to_file("res://scenes/level_editor.tscn")

func _on_delete_pressed(file_path: String):
	"""Delete the selected custom level"""
	# TODO: Add confirmation dialog
	if DirAccess.remove_absolute(file_path) == OK:
		print("Deleted level: ", file_path)
		# Refresh the list
		_clear_grid()
		_load_custom_levels()
	else:
		push_error("Failed to delete level: ", file_path)

func _clear_grid():
	"""Clear all children from grid"""
	var grid = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
	for child in grid.get_children():
		child.queue_free()

func _on_back_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
