extends Control

@onready var code_input = $HSplitContainer/CodePanel/VBoxContainer/CodeInput
@onready var run_button = $HSplitContainer/CodePanel/VBoxContainer/ButtonContainer/RunButton
@onready var restart_button = $HSplitContainer/CodePanel/VBoxContainer/ButtonContainer/RestartButton
@onready var next_level_button = $HSplitContainer/CodePanel/VBoxContainer/ButtonContainer/NextLevelButton
@onready var output_label = $HSplitContainer/CodePanel/VBoxContainer/OutputLabel
@onready var title_label = $HSplitContainer/CodePanel/VBoxContainer/TitleLabel
@onready var player = $HSplitContainer/GamePanel/GridBackground/Level/Player
@onready var code_executor = $CodeExecutor

var grid_manager: GridManager
var is_level_complete: bool = false
var player_is_dead: bool = false
var current_level_id: int = 1
var level_definitions: Node

# Available commands and keywords for code completion
var available_commands = ["moveRight()", "moveLeft()", "moveUp()", "moveDown()", "frontIsClear()", "goalReached()", "onHazard()", "leftIsClear()", "rightIsClear()"]
var available_keywords = ["if", "else", "elif", "for", "while", "do", "function", "return", "in", "range", "and", "or", "not"]

# Example code snippets
var examples = {
	"simple_moves": """# Simple movement
moveRight()
moveRight()
moveUp()
moveLeft()""",
	
	"for_loop": """# For loop example
for (i in range(5)) {
	moveRight()
}""",
	
	"if_else": """# If-else example
x = 5
if (x > 3) {
	moveUp()
	moveUp()
} else {
	moveDown()
}""",
	
	"while_loop": """# While loop example
count = 0
while (count < 3) {
	moveRight()
	count = count + 1
}""",
	
	"sensing": """# Using sensors
while(frontIsClear()) {
	moveRight()
}
moveDown()""",
	
	"function": """# Function example
function square() {
	moveRight()
	moveDown()
	moveLeft()
	moveUp()
}

square()
square()""",
	
	"nested": """# Nested control flow
for (i in range(3)) {
	if (i == 1) {
		moveUp()
	} else {
		moveRight()
	}
}"""
}

func _ready():
	run_button.pressed.connect(_on_run_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	next_level_button.pressed.connect(_on_next_level_button_pressed)
	code_executor.execution_complete.connect(_on_execution_complete)
	code_executor.execution_error.connect(_on_execution_error)
	
	# Load level definitions
	level_definitions = load("res://scripts/level_definitions.gd").new()
	
	# Enable code completion
	code_input.code_completion_enabled = true
	code_input.code_completion_prefixes = ["move", "if", "for", "while", "function"]
	code_input.code_completion_requested.connect(_on_code_completion_requested)
	
	# Set default example code
	code_input.text = examples["simple_moves"]
	
	_update_help_text()
	
	# Load level 1
	await get_tree().process_frame
	load_level(1)

func load_level(level_id: int):
	"""Load a level by ID"""
	current_level_id = level_id
	var level_def = level_definitions.get_level(level_id)
	
	if level_def.is_empty():
		push_error("Level %d not found!" % level_id)
		return
	
	# Find or create GridManager
	var level_node = get_node("HSplitContainer/GamePanel/GridBackground/Level")
	grid_manager = level_node.get_node_or_null("GridManager")
	
	if not grid_manager:
		grid_manager = GridManager.new()
		grid_manager.name = "GridManager"
		level_node.add_child(grid_manager)
		# Connect signals
		grid_manager.level_completed.connect(_on_level_completed)
		grid_manager.player_died.connect(_on_player_died)
	
	grid_manager.load_level_from_string(level_def["layout"])
	
	# Connect grid manager to player
	if player:
		player.grid_manager = grid_manager
		player.reset_position()
	
	# Explicitly set grid manager reference and refresh grid visual
	var grid_bg = get_node("HSplitContainer/GamePanel/GridBackground")
	if grid_bg:
		grid_bg.grid_manager = grid_manager
		if grid_bg.has_method("refresh"):
			grid_bg.refresh()
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	next_level_button.disabled = true
	
	# Update code editor with starter code
	code_input.text = level_def["starter_code"]
	
	# Update title
	title_label.text = "Level %d: %s" % [level_id, level_def["level_name"]]
	
	# Update output with hint
	output_label.text = level_def["hint_text"]
	
	print("Loaded Level %d: %s" % [level_id, level_def["level_name"]])

func _on_code_completion_requested():
	# Add all available commands as completion options
	for command in available_commands:
		code_input.add_code_completion_option(
			CodeEdit.KIND_FUNCTION,
			command,
			command,
			Color.CYAN
		)
	
	# Add keywords
	for keyword in available_keywords:
		code_input.add_code_completion_option(
			CodeEdit.KIND_MEMBER,
			keyword,
			keyword,
			Color.ORANGE
		)
	
	# Update the completion menu
	code_input.update_code_completion_options(true)

func _on_run_button_pressed():
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	
	var code = code_input.text
	output_label.text = "Executing..."
	run_button.disabled = true
	player.reset_position()
	code_executor.execute_code(code, player)

func _on_execution_complete():
	if is_level_complete:
		output_label.text = "🎉 Level Complete! Press 'Next Level' to continue!"
		next_level_button.disabled = false
	elif player_is_dead:
		output_label.text = "💀 You died! Click 'Restart' to try again."
	else:
		output_label.text = "Execution complete! ✓"
	run_button.disabled = false

func _on_restart_button_pressed():
	"""Restart current level"""
	load_level(current_level_id)

func _on_next_level_button_pressed():
	"""Load next level"""
	var next_level = current_level_id + 1
	if next_level <= level_definitions.get_level_count():
		load_level(next_level)
	else:
		output_label.text = "🎉 Congratulations! You completed all levels!"
		next_level_button.disabled = true

func _on_execution_error(error_msg: String):
	output_label.text = "Error: " + error_msg
	run_button.disabled = false

func _on_level_completed():
	"""Called when player reaches goal"""
	is_level_complete = true
	print("🎉 Level completed!")

func _on_player_died():
	"""Called when player hits hazard"""
	player_is_dead = true
	code_executor.stop_execution()
	print("💀 Player died!")

func _update_help_text():
	output_label.text = """Commands:
moveRight(), moveLeft()
moveUp(), moveDown()

Control Flow:
if/elif/else, for, while, do-while

Examples: Press F1-F6
F1: Simple moves
F2: For loop
F3: If-else
F4: While loop
F5: Function
F6: Nested

Click Run to execute!"""

func _input(event):
	# Level selection with number keys 1-8
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			var level_num = event.keycode - KEY_0
			if level_num <= level_definitions.get_level_count():
				load_level(level_num)
				print("Switched to Level %d" % level_num)
		
		# Example shortcuts (F1-F6)
		match event.keycode:
			KEY_F1:
				code_input.text = examples["simple_moves"]
				_update_help_text()
			KEY_F2:
				code_input.text = examples["for_loop"]
				_update_help_text()
			KEY_F3:
				code_input.text = examples["if_else"]
				_update_help_text()
			KEY_F4:
				code_input.text = examples["while_loop"]
				_update_help_text()
			KEY_F5:
				code_input.text = examples["function"]
				_update_help_text()
			KEY_F6:
				code_input.text = examples["nested"]
				_update_help_text()
