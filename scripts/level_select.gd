extends Control

var level_definitions: Node

func _ready():
	# Load level definitions
	level_definitions = load("res://scripts/level_definitions.gd").new()
	
	# Connect back button
	$MarginContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Create level buttons
	_create_level_buttons()

func _create_level_buttons():
	"""Create a button for each level"""
	var grid = $MarginContainer/VBoxContainer/ScrollContainer/GridContainer
	var level_count = level_definitions.get_level_count()
	
	for i in range(level_count):
		var level_id = i + 1
		var level_def = level_definitions.get_level(level_id)
		
		# Create button
		var button = Button.new()
		button.custom_minimum_size = Vector2(200, 150)
		button.text = "Level %d\n%s\n\n⭐" % [level_id, level_def["level_name"]]
		button.add_theme_font_size_override("font_size", 16)
		
		# Color based on difficulty
		var difficulty = level_def.get("difficulty", 1)
		if difficulty >= 3:
			button.modulate = Color(1.0, 0.7, 0.7)  # Harder = reddish
		elif difficulty == 2:
			button.modulate = Color(1.0, 1.0, 0.7)  # Medium = yellowish
		else:
			button.modulate = Color(0.7, 1.0, 0.7)  # Easy = greenish
		
		# Connect button
		button.pressed.connect(_on_level_pressed.bind(level_id))
		
		grid.add_child(button)

func _on_level_pressed(level_id: int):
	"""Load the selected level"""
	# Store the selected level for main scene to load
	get_tree().root.set_meta("selected_level", level_id)
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_back_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
