extends Control

@onready var start_button = $MarginContainer/VBoxContainer/StartButton
@ontml:parameter name="level_select_button = $MarginContainer/VBoxContainer/LevelSelectButton
@onready var quit_button = $MarginContainer/VBoxContainer/QuitButton
@onready var title_label = $MarginContainer/VBoxContainer/TitleLabel

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Load progress on startup
	if GameManager.instance:
		GameManager.instance.load_progress()

func _on_start_pressed():
	# Start from level 1 or continue from last level
	if GameManager.instance:
		get_tree().change_scene_to_file("res://scenes/game_scene.tscn")
	else:
		push_error("GameManager not found!")

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/menus/level_select.tscn")

func _on_quit_pressed():
	get_tree().quit()
