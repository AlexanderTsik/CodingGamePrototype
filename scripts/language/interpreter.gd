extends Node
class_name Interpreter

signal execution_complete
signal execution_error(error_msg: String)
signal line_executing(line_number: int)
signal line_executed(line_number: int, node_type: String)
signal variable_changed(var_name: String, value)
signal function_entered(func_name: String, params: Dictionary)
signal function_exited(func_name: String, return_value)
signal execution_paused
signal execution_resumed

# Environment/Scope management
var global_scope: Dictionary = {}
var scope_stack: Array = []  # Stack of scopes for nested blocks/functions
var current_player: Node2D

# Function storage
var user_functions: Dictionary = {}

# Execution control
var is_running: bool = false
var max_iterations: int = 10000  # Prevent infinite loops
var iteration_count: int = 0
var execution_speed: float = 1.0  # Speed multiplier (1.0 = normal)

# Return value handling
var return_value = null
var should_return: bool = false

# Debug management
var debug_manager: DebugManager = null
var current_call_depth: int = 0
const BASE_DELAY: float = 0.3

func execute(ast: ASTNodes.ProgramNode, player: Node2D):
	if is_running:
		push_error("Interpreter is already running")
		return
	
	current_player = player
	global_scope = {}
	scope_stack = []
	user_functions = {}
	is_running = true
	iteration_count = 0
	return_value = null
	should_return = false
	reset_debug_state()
	
	_push_scope()  # Global scope
	
	# First pass: collect function definitions
	for statement in ast.statements:
		if statement is ASTNodes.FunctionNode:
			user_functions[statement.function_name] = statement
	
	# Second pass: execute statements
	for statement in ast.statements:
		if statement is ASTNodes.FunctionNode:
			continue  # Skip function definitions (already collected)
		
		await _execute_statement(statement)
		
		if should_return:
			break
		
		if not is_running:
			break
	
	_pop_scope()
	is_running = false
	execution_complete.emit()

func stop():
	is_running = false

# ============================================
# Statement Execution
# ============================================

func _execute_statement(statement):
	if not is_running:
		return
	
	iteration_count += 1
	if iteration_count > max_iterations:
		_error("Maximum iteration limit reached. Possible infinite loop?")
		is_running = false
		return
	
	if statement == null:
		return
	
	# Emit line execution signal with line number and type
	if statement.line_number > 0:
		print("DEBUG [Interpreter]: Emitting line_executing for line %d" % statement.line_number)
		line_executing.emit(statement.line_number)
		
		# Check if we should pause at this line
		var should_pause = false
		
		if debug_manager != null:
			# First check conditional breakpoints
			var current_vars = _get_current_variables()
			if debug_manager.should_break_at(statement.line_number, current_vars):
				should_pause = true
			# Then check debug mode (step over/into/out)
			elif debug_manager.should_pause_at_line(statement.line_number, current_call_depth):
				should_pause = true
		
		if should_pause:
			execution_paused.emit()
			print("DEBUG [Interpreter]: Paused at line %d" % statement.line_number)
			
			# Wait for continue signal or step signal
			await debug_manager.continue_requested
			execution_resumed.emit()
			print("DEBUG [Interpreter]: Resumed from line %d" % statement.line_number)
		
		# Apply execution delay with speed multiplier
		var delay = BASE_DELAY / execution_speed
		await get_tree().create_timer(delay).timeout
	
	if statement is ASTNodes.CallNode:
		await _execute_function_call(statement)
	
	elif statement is ASTNodes.AssignmentNode:
		await _execute_assignment(statement)
	
	elif statement is ASTNodes.IfNode:
		await _execute_if(statement)
	
	elif statement is ASTNodes.ForNode:
		await _execute_for(statement)
	
	elif statement is ASTNodes.WhileNode:
		await _execute_while(statement)
	
	elif statement is ASTNodes.DoWhileNode:
		await _execute_do_while(statement)
	
	elif statement is ASTNodes.ReturnNode:
		await _execute_return(statement)
	
	elif statement is ASTNodes.FunctionNode:
		# Function definitions are already collected
		pass
	
	elif statement is ASTNodes.BlockNode:
		await _execute_block(statement.statements)
	
	else:
		_error("Unknown statement type: %s" % statement.node_type)

func _execute_builtin_command(cmd_name: String, arguments: Array):
	if not current_player:
		_error("No player available for command execution")
		return
	
	# Evaluate arguments (if any)
	var args = []
	for arg in arguments:
		args.append(_evaluate_expression(arg))
	
	# Execute built-in commands
	match cmd_name:
		# Turn-based movement system
		"move":
			current_player.move()
			await get_tree().create_timer(0.3).timeout
		"turnRight":
			current_player.turnRight()
			await get_tree().create_timer(0.1).timeout
		"turnLeft":
			current_player.turnLeft()
			await get_tree().create_timer(0.1).timeout
		"turnBack":
			current_player.turnBack()
			await get_tree().create_timer(0.1).timeout
		_:
			_error("Unknown built-in command: %s" % cmd_name)

func _execute_function_call(call: ASTNodes.CallNode):
	var func_name = call.function_name
	
	# Check if it's a built-in command first
	if func_name in ["move", "turnRight", "turnLeft", "turnBack"]:
		await _execute_builtin_command(func_name, call.arguments)
		return
	
	# Check if it's a sensing function (returns a value)
	if func_name in ["frontIsClear", "leftIsClear", "rightIsClear", "goalReached", "onHazard"]:
		# These are handled in _evaluate_expression, not here
		_error("Sensing function '%s' must be used in an expression (if/while condition)" % func_name)
		return
	
	# Otherwise, call user-defined function
	if not func_name in user_functions:
		_error("Undefined function: %s" % func_name)
		return
	
	var func_def = user_functions[func_name]
	
	# Evaluate arguments
	var args = []
	for arg in call.arguments:
		args.append(_evaluate_expression(arg))
	
	# Check parameter count
	if args.size() != func_def.parameters.size():
		_error("Function %s expects %d arguments, got %d" % [func_name, func_def.parameters.size(), args.size()])
		return
	
	# Create new scope for function
	_push_scope()
	
	# Build params dictionary for signal
	var params_dict = {}
	for i in range(func_def.parameters.size()):
		params_dict[func_def.parameters[i]] = args[i]
	
	# Emit function entered signal
	current_call_depth += 1
	function_entered.emit(func_name, params_dict)
	
	# Bind parameters
	for i in range(func_def.parameters.size()):
		_set_variable(func_def.parameters[i], args[i])
	
	# Execute function body
	var previous_return_state = should_return
	should_return = false
	
	for statement in func_def.body:
		await _execute_statement(statement)
		if should_return:
			break
	
	should_return = previous_return_state
	
	# Emit function exited signal
	current_call_depth -= 1
	function_exited.emit(func_name, return_value)
	
	_pop_scope()

func _execute_assignment(assign: ASTNodes.AssignmentNode):
	var value = _evaluate_expression(assign.value)
	_set_variable(assign.variable_name, value)
	# Emit signal for variable change
	variable_changed.emit(assign.variable_name, value)

func _execute_if(if_node: ASTNodes.IfNode):
	var condition = _evaluate_expression(if_node.condition)
	
	if _is_truthy(condition):
		# Execute true branch
		await _execute_block(if_node.true_branch)
	else:
		# Check elif branches
		var executed = false
		for elif_branch in if_node.elif_branches:
			var elif_condition = _evaluate_expression(elif_branch.condition)
			if _is_truthy(elif_condition):
				await _execute_block(elif_branch.body)
				executed = true
				break
		
		# Execute else branch if no elif was executed
		if not executed and if_node.false_branch.size() > 0:
			await _execute_block(if_node.false_branch)

func _execute_for(for_node: ASTNodes.ForNode):
	# Evaluate iterable
	var iterable = _evaluate_expression(for_node.iterable)
	
	if not iterable is Array:
		_error("For loop iterable must be an array")
		return
	
	_push_scope()
	
	for value in iterable:
		_set_variable(for_node.iterator_var, value)
		await _execute_block(for_node.body)
		
		if should_return or not is_running:
			break
	
	_pop_scope()

func _execute_while(while_node: ASTNodes.WhileNode):
	_push_scope()
	
	var loop_count = 0
	while _is_truthy(_evaluate_expression(while_node.condition)):
		await _execute_block(while_node.body)
		
		if should_return or not is_running:
			break
		
		loop_count += 1
		if loop_count > max_iterations:
			_error("While loop exceeded maximum iterations")
			break
	
	_pop_scope()

func _execute_do_while(do_while_node: ASTNodes.DoWhileNode):
	_push_scope()
	
	var loop_count = 0
	while true:
		await _execute_block(do_while_node.body)
		
		if should_return or not is_running:
			break
		
		if not _is_truthy(_evaluate_expression(do_while_node.condition)):
			break
		
		loop_count += 1
		if loop_count > max_iterations:
			_error("Do-while loop exceeded maximum iterations")
			break
	
	_pop_scope()

func _execute_return(return_node: ASTNodes.ReturnNode):
	if return_node.value:
		return_value = _evaluate_expression(return_node.value)
	else:
		return_value = null
	should_return = true

func _execute_block(statements: Array):
	for statement in statements:
		await _execute_statement(statement)
		if should_return or not is_running:
			break

# ============================================
# Expression Evaluation
# ============================================

func _evaluate_expression(expr):
	if expr == null:
		return null
	
	if expr is ASTNodes.NumberNode:
		return expr.value
	
	elif expr is ASTNodes.StringNode:
		return expr.value
	
	elif expr is ASTNodes.IdentifierNode:
		return _get_variable(expr.name)
	
	elif expr is ASTNodes.BinaryOpNode:
		return _evaluate_binary_op(expr)
	
	elif expr is ASTNodes.UnaryOpNode:
		return _evaluate_unary_op(expr)
	
	elif expr is ASTNodes.RangeNode:
		return _evaluate_range(expr)
	
	elif expr is ASTNodes.CallNode:
		# Check if it's a sensing function (built-in query functions)
		var func_name = expr.function_name
		if func_name in ["frontIsClear", "leftIsClear", "rightIsClear", "goalReached", "onHazard"]:
			return _evaluate_sensing_function(func_name)
		
		# For user-defined functions, we can't await here since this is sync
		_error("Function calls in expressions not yet supported (except sensing functions)")
		return null
	
	else:
		_error("Unknown expression type: %s" % expr.node_type)
		return null

func _evaluate_sensing_function(func_name: String):
	"""Evaluate built-in sensing functions that return boolean values"""
	if not current_player:
		_error("No player available for sensing function")
		return false
	
	match func_name:
		"frontIsClear":
			return current_player.is_front_clear()
		"leftIsClear":
			return current_player.is_left_clear()
		"rightIsClear":
			return current_player.is_right_clear()
		"goalReached":
			return current_player.is_on_goal()
		"onHazard":
			return current_player.is_on_hazard()
		_:
			_error("Unknown sensing function: %s" % func_name)
			return false

func _evaluate_binary_op(op: ASTNodes.BinaryOpNode):
	var left = _evaluate_expression(op.left)
	var right = _evaluate_expression(op.right)
	
	match op.operator:
		"+":
			return left + right
		"-":
			return left - right
		"*":
			return left * right
		"/":
			if right == 0:
				_error("Division by zero")
				return 0
			return left / right
		"%":
			if right == 0:
				_error("Modulo by zero")
				return 0
			return left % right
		"==":
			return left == right
		"!=":
			return left != right
		"<":
			return left < right
		">":
			return left > right
		"<=":
			return left <= right
		">=":
			return left >= right
		"and":
			return _is_truthy(left) and _is_truthy(right)
		"or":
			return _is_truthy(left) or _is_truthy(right)
		_:
			_error("Unknown operator: %s" % op.operator)
			return null

func _evaluate_unary_op(op: ASTNodes.UnaryOpNode):
	var operand = _evaluate_expression(op.operand)
	
	match op.operator:
		"-":
			return -operand
		"not", "!":
			return not _is_truthy(operand)
		_:
			_error("Unknown unary operator: %s" % op.operator)
			return null

func _evaluate_range(range_node: ASTNodes.RangeNode) -> Array:
	var start = _evaluate_expression(range_node.start)
	var end = _evaluate_expression(range_node.end)
	var step = 1
	
	if range_node.step:
		step = _evaluate_expression(range_node.step)
	
	if not (start is int or start is float):
		_error("Range start must be a number")
		return []
	
	if not (end is int or end is float):
		_error("Range end must be a number")
		return []
	
	var result = []
	if step > 0:
		var i = start
		while i < end:
			result.append(i)
			i += step
	elif step < 0:
		var i = start
		while i > end:
			result.append(i)
			i += step
	else:
		_error("Range step cannot be zero")
	
	return result

func _is_truthy(value) -> bool:
	if value == null:
		return false
	if value is bool:
		return value
	if value is int or value is float:
		return value != 0
	if value is String:
		return value != ""
	if value is Array:
		return value.size() > 0
	return true

# ============================================
# Scope/Environment Management
# ============================================

func _push_scope():
	scope_stack.append({})

func _pop_scope():
	if scope_stack.size() > 0:
		scope_stack.pop_back()

func _set_variable(name: String, value):
	# Set in current scope
	if scope_stack.size() > 0:
		scope_stack[scope_stack.size() - 1][name] = value
	else:
		global_scope[name] = value

func _get_variable(name: String):
	# Search from innermost to outermost scope
	for i in range(scope_stack.size() - 1, -1, -1):
		if name in scope_stack[i]:
			return scope_stack[i][name]
	
	# Check global scope
	if name in global_scope:
		return global_scope[name]
	
	_error("Undefined variable: %s" % name)
	return null

# ============================================
# Debug Control
# ============================================

func set_debug_manager(manager: DebugManager):
	"""Attach a debug manager to control execution"""
	debug_manager = manager
	print("DEBUG [Interpreter]: Debug manager attached")

func set_execution_speed(speed: float):
	"""Set execution speed multiplier (0.25x to 5x)"""
	execution_speed = clamp(speed, 0.25, 5.0)
	print("DEBUG [Interpreter]: Execution speed set to %.2fx" % execution_speed)

func reset_debug_state():
	"""Reset debug state for new execution"""
	current_call_depth = 0
	if debug_manager != null:
		debug_manager.reset()

func _get_current_variables() -> Dictionary:
	"""Get all currently accessible variables for breakpoint condition evaluation"""
	var all_vars = {}
	
	# Add global scope variables
	for key in global_scope.keys():
		all_vars[key] = global_scope[key]
	
	# Add variables from current scope stack (local + function scopes)
	for scope in scope_stack:
		for key in scope.keys():
			all_vars[key] = scope[key]
	
	return all_vars

# ============================================
# Error Handling
# ============================================

func _error(message: String):
	# Try to provide helpful suggestions
	var suggestion = _get_error_suggestion(message)
	var full_message = "Runtime error: %s" % message
	if suggestion != "":
		full_message += "\nSuggestion: %s" % suggestion
	
	push_error(full_message)
	execution_error.emit(full_message)
	is_running = false

func _get_error_suggestion(error_msg: String) -> String:
	# Provide helpful suggestions based on error type
	if "Undefined variable" in error_msg:
		return "Did you forget to assign a value to this variable?"
	elif "Undefined function" in error_msg:
		var common_commands = {
			"moveright": "Did you mean 'move()' and 'turnRight()'?",
			"moveleft": "Did you mean 'move()' and 'turnLeft()'?",
			"moveup": "Did you mean 'move()' with proper turning?",
			"movedown": "Did you mean 'move()' with proper turning?"
		}
		for typo in common_commands:
			if typo in error_msg.to_lower():
				return common_commands[typo]
		return "Make sure the function is defined before calling it."
	elif "Division by zero" in error_msg or "Modulo by zero" in error_msg:
		return "Check your math - you can't divide by zero!"
	elif "Maximum iteration limit" in error_msg:
		return "Your loop might be infinite. Check your loop conditions."
	elif "must be a number" in error_msg:
		return "Make sure you're using numbers in mathematical operations."
	elif "must be an array" in error_msg:
		return "For loops need an iterable like range(5)."
	
	return ""
