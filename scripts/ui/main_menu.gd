extends Control

func _ready():
	# Connect buttons
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_pressed)
	$CenterContainer/VBoxContainer/LevelEditorButton.pressed.connect(_on_level_editor_pressed)
	$CenterContainer/VBoxContainer/CustomLevelsButton.pressed.connect(_on_custom_levels_pressed)
	$CenterContainer/VBoxContainer/HowToPlayButton.pressed.connect(_on_how_to_play_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$HowToPlayPopup/MarginContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_popup_pressed)

func _on_start_pressed():
	"""Start game from Level 1"""
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_level_select_pressed():
	"""Open level select screen"""
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_level_editor_pressed():
	"""Open level editor"""
	get_tree().change_scene_to_file("res://scenes/ui/level_editor.tscn")

func _on_custom_levels_pressed():
	"""Open custom levels browser"""
	get_tree().change_scene_to_file("res://scenes/ui/custom_levels.tscn")

func _on_how_to_play_pressed():
	"""Show instructions popup"""
	$HowToPlayPopup.visible = true

func _on_close_popup_pressed():
	"""Hide instructions popup"""
	$HowToPlayPopup.visible = false

func _on_quit_pressed():
	"""Quit the game"""
	get_tree().quit()
