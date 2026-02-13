extends Control

@onready var code_input = $HSplitContainer/CodePanel/VBoxContainer/CodeInput
@onready var run_button = $HSplitContainer/CodePanel/VBoxContainer/RunButton
@onready var output_label = $HSplitContainer/CodePanel/VBoxContainer/OutputLabel
@onready var player = $HSplitContainer/GamePanel/GridBackground/Level/Player
@onready var code_executor = $CodeExecutor

# Available commands and keywords for code completion
var available_commands = ["moveRight()", "moveLeft()", "moveUp()", "moveDown()"]
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
	code_executor.execution_complete.connect(_on_execution_complete)
	code_executor.execution_error.connect(_on_execution_error)
	
	# Enable code completion
	code_input.code_completion_enabled = true
	code_input.code_completion_prefixes = ["move", "if", "for", "while", "function"]
	code_input.code_completion_requested.connect(_on_code_completion_requested)
	
	# Set default example code
	code_input.text = examples["simple_moves"]
	
	_update_help_text()
	
	# Wait for level manager to load, then reset player position
	await get_tree().process_frame
	if player and player.level_manager:
		player.reset_position()

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
	var code = code_input.text
	output_label.text = "Executing..."
	run_button.disabled = true
	player.reset_position()
	code_executor.execute_code(code, player)

func _on_execution_complete():
	output_label.text = "Execution complete! ✓"
	run_button.disabled = false

func _on_execution_error(error_msg: String):
	output_label.text = "Error: " + error_msg
	run_button.disabled = false

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
	if event is InputEventKey and event.pressed and not event.echo:
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
