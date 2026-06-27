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
	interpreter.line_executing.connect(_on_line_executing)

func execute_code(code: String, player: Node2D):
	# Tokenize — surface the first error instead of running a broken AST.
	var lexer = Lexer.new()
	var tokens = lexer.tokenize(code)
	if not lexer.errors.is_empty():
		execution_error.emit(lexer.errors[0])
		return

	# Parse
	var parser = Parser.new()
	var ast = parser.parse(tokens)
	if not parser.errors.is_empty():
		execution_error.emit(parser.errors[0])
		return

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

func _on_line_executing(line_number: int):
	line_executing.emit(line_number)
