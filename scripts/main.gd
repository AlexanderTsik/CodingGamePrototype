extends Control

@onready var code_input = $HSplitContainer/CodePanel/VBoxContainer/CodeInput
@onready var run_button = $HSplitContainer/CodePanel/VBoxContainer/RunButton
@onready var output_label = $HSplitContainer/CodePanel/VBoxContainer/OutputLabel
@onready var player = $HSplitContainer/GamePanel/Level/Player
@onready var code_executor = $CodeExecutor

# Available commands for code completion
var available_commands = ["moveRight()", "moveLeft()", "moveUp()", "moveDown()"]

func _ready():
	run_button.pressed.connect(_on_run_button_pressed)
	code_executor.execution_complete.connect(_on_execution_complete)
	code_executor.execution_error.connect(_on_execution_error)
	
	# Enable code completion
	code_input.code_completion_enabled = true
	code_input.code_completion_prefixes = ["move"]
	code_input.code_completion_requested.connect(_on_code_completion_requested)
	
	output_label.text = "Available commands:\nmoveRight()\nmoveLeft()\nmoveUp()\nmoveDown()\n\nDefine functions:\nfunction myFunc(){\n  moveRight()\n}\n\nClick Run to execute!"

func _on_code_completion_requested():
	# Clear any existing options
	code_input.clear_code_completion_options()
	
	# Add all available commands as completion options
	for command in available_commands:
		code_input.add_code_completion_option(
			CodeEdit.KIND_FUNCTION,
			command,
			command,
			Color.CYAN
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
