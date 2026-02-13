extends Node

signal execution_complete
signal execution_error(error_msg: String)
signal line_executing(line_number: int)

var interpreter: Interpreter

func _ready():
	# Create interpreter instance
	interpreter = Interpreter.new()
	add_child(interpreter)
	
	# Connect signals
	interpreter.execution_complete.connect(_on_execution_complete)
	interpreter.execution_error.connect(_on_execution_error)

func execute_code(code: String, player: Node2D):
	# Tokenize
	var lexer = Lexer.new()
	var tokens = lexer.tokenize(code)
	
	# Check for lexer errors (would be in push_error)
	# For now, we continue even if there are warnings
	
	# Parse
	var parser = Parser.new()
	var ast = parser.parse(tokens)
	
	# Check for parser errors
	# For now, we continue even if there are warnings
	
	# Execute
	interpreter.execute(ast, player)

func stop_execution():
	"""Stop the current code execution"""
	if interpreter:
		interpreter.is_running = false

func _on_execution_complete():
	execution_complete.emit()

func _on_execution_error(error_msg: String):
	execution_error.emit(error_msg)
