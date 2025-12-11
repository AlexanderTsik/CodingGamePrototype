extends Node

signal execution_complete
signal execution_error(error_msg: String)
signal line_executing(line_number: int)

var current_player: Node2D
var commands: Array = []  # Each command is now a dictionary: {type: "command", line: line_number}
var current_command_index: int = 0
var executing: bool = false

# Store user-defined functions
var user_functions: Dictionary = {}
var original_code_lines: Array = []

func execute_code(code: String, player: Node2D):
	current_player = player
	commands.clear()
	current_command_index = 0
	user_functions.clear()
	original_code_lines = code.split("\n")
	
	# First pass: parse function definitions
	var parse_result = _parse_functions(code)
	if parse_result != "":
		execution_error.emit(parse_result)
		return
	
	# Second pass: parse main code (outside functions)
	var lines = code.split("\n")
	var inside_function = false
	var line_number = 0
	
	for line in lines:
		var trimmed = line.strip_edges()
		
		# Check if entering or exiting function definition
		if trimmed.begins_with("function "):
			inside_function = true
			line_number += 1
			continue
		elif trimmed == "}":
			inside_function = false
			line_number += 1
			continue
		
		# Skip lines inside function definitions
		if inside_function:
			line_number += 1
			continue
		
		# Skip empty lines and comments
		if trimmed.is_empty() or trimmed.begins_with("#"):
			line_number += 1
			continue
		
		# Parse command or function call
		var parse_error = _parse_command(trimmed, line_number)
		if parse_error != "":
			execution_error.emit(parse_error)
			return
		
		line_number += 1
	
	if commands.is_empty():
		execution_complete.emit()
		return
	
	executing = true
	_execute_next_command()

func _parse_functions(code: String) -> String:
	var lines = code.split("\n")
	var i = 0
	
	while i < lines.size():
		var line = lines[i].strip_edges()
		
		# Check for function definition
		if line.begins_with("function "):
			# Extract function name
			var func_def = line.substr(9).strip_edges()  # Remove "function "
			if not func_def.ends_with("{"):
				return "Function definition must end with '{': " + line
			
			var func_name = func_def.substr(0, func_def.length() - 1).strip_edges()
			if not func_name.ends_with("()"):
				return "Function name must end with '()': " + func_name
			
			func_name = func_name.substr(0, func_name.length() - 2)  # Remove "()"
			
			if func_name.is_empty():
				return "Function name cannot be empty"
			
			# Parse function body
			var func_commands = []
			i += 1
			var func_start_line = i
			
			while i < lines.size():
				var body_line = lines[i].strip_edges()
				
				if body_line == "}":
					break
				
				if not body_line.is_empty() and not body_line.begins_with("#"):
					func_commands.append({"command": body_line, "line": i})
				
				i += 1
			
			if i >= lines.size():
				return "Function '" + func_name + "' is missing closing brace '}'"
			
			user_functions[func_name] = func_commands
		
		i += 1
	
	return ""

func _parse_command(command_str: String, line_num: int) -> String:
	# Check if it's a user-defined function call
	if command_str.ends_with("()"):
		var func_name = command_str.substr(0, command_str.length() - 2)
		
		if user_functions.has(func_name):
			# Expand the function call into its commands
			for func_command in user_functions[func_name]:
				var error = _add_basic_command(func_command.command, func_command.line)
				if error != "":
					return error
			return ""
		else:
			# Check if it's a built-in command
			return _add_basic_command(command_str, line_num)
	
	return "Invalid command format: " + command_str

func _add_basic_command(command_str: String, line_num: int) -> String:
	if not command_str.ends_with("()"):
		return "Invalid command format: " + command_str
	
	var func_name = command_str.substr(0, command_str.length() - 2)
	
	if func_name == "moveRight":
		commands.append({"type": "right", "line": line_num})
		return ""
	elif func_name == "moveLeft":
		commands.append({"type": "left", "line": line_num})
		return ""
	elif func_name == "moveUp":
		commands.append({"type": "up", "line": line_num})
		return ""
	elif func_name == "moveDown":
		commands.append({"type": "down", "line": line_num})
		return ""
	else:
		return "Unknown function: " + func_name + "()"

func _execute_next_command():
	if current_command_index >= commands.size():
		executing = false
		execution_complete.emit()
		return
	
	var command = commands[current_command_index]
	current_command_index += 1
	
	# Highlight the line being executed
	line_executing.emit(command.line)
	
	match command.type:
		"right":
			current_player.move_right()
		"left":
			current_player.move_left()
		"up":
			current_player.move_up()
		"down":
			current_player.move_down()
	
	await get_tree().create_timer(0.3).timeout
	_execute_next_command()
