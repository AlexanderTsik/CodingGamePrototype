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
const MOVE_TIME: float = 0.3   # base seconds for one move animation (scaled by speed)
const TURN_TIME: float = 0.15  # base seconds to pause after a turn (scaled by speed)
var instant: bool = false      # tests set this to skip all delays/animation

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
	var node_type := "Unknown"
	
	iteration_count += 1
	if iteration_count > max_iterations:
		_error("Maximum iteration limit reached. Possible infinite loop?")
		is_running = false
		return
	
	if statement == null:
		return
	
	# Emit line execution signal with line number and type
	if statement.line_number > 0:
		Dbg.p("DEBUG [Interpreter]: Emitting line_executing for line %d" % statement.line_number)
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
			Dbg.p("DEBUG [Interpreter]: Paused at line %d" % statement.line_number)
			
			# Wait for continue signal or step signal
			await debug_manager.continue_requested
			execution_resumed.emit()
			Dbg.p("DEBUG [Interpreter]: Resumed from line %d" % statement.line_number)
		
		# Pacing comes from the action commands (move/turn); pure-logic
		# statements run with no artificial per-line delay.
	
	if statement is ASTNodes.CallNode:
		node_type = "Call"
		await _execute_function_call(statement)
	
	elif statement is ASTNodes.AssignmentNode:
		node_type = "Assignment"
		await _execute_assignment(statement)
	
	elif statement is ASTNodes.IfNode:
		node_type = "If"
		await _execute_if(statement)
	
	elif statement is ASTNodes.ForNode:
		node_type = "For"
		await _execute_for(statement)
	
	elif statement is ASTNodes.WhileNode:
		node_type = "While"
		await _execute_while(statement)
	
	elif statement is ASTNodes.DoWhileNode:
		node_type = "DoWhile"
		await _execute_do_while(statement)
	
	elif statement is ASTNodes.ReturnNode:
		node_type = "Return"
		await _execute_return(statement)
	
	elif statement is ASTNodes.FunctionNode:
		node_type = "Function"
		# Function definitions are already collected
		pass
	
	elif statement is ASTNodes.BlockNode:
		node_type = "Block"
		await _execute_block(statement.statements)
	
	else:
		_error("Unknown statement type: %s" % statement.node_type)

	if statement.line_number > 0:
		line_executed.emit(statement.line_number, node_type)

func _execute_builtin_command(cmd_name: String, arguments: Array):
	if not current_player:
		_error("No player available for command execution")
		return
	
	# Evaluate arguments (if any)
	var args = []
	for arg in arguments:
		args.append(await _evaluate_expression(arg))
	
	# Execute built-in commands. Pacing scales with execution_speed and the
	# interpreter awaits the move animation so it never races ahead of the bug.
	match cmd_name:
		"move":
			await current_player.move(0.0 if instant else MOVE_TIME / execution_speed)
		"turnRight":
			current_player.turnRight()
			await _beat(TURN_TIME)
		"turnLeft":
			current_player.turnLeft()
			await _beat(TURN_TIME)
		"turnBack":
			current_player.turnBack()
			await _beat(TURN_TIME)
		_:
			_error("Unknown built-in command: %s" % cmd_name)

func _beat(base: float) -> void:
	# One paced beat between steps, scaled by execution speed. Skipped entirely
	# in `instant` mode (tests) so runs complete without waiting on timers.
	if instant:
		return
	var d := base / execution_speed
	if d > 0.0:
		await get_tree().create_timer(d).timeout

func _execute_function_call(call_node: ASTNodes.CallNode):
	var func_name = call_node.function_name
	
	# Check if it's a built-in command first
	if func_name in ["move", "turnRight", "turnLeft", "turnBack"]:
		await _execute_builtin_command(func_name, call_node.arguments)
		return
	
	# Check if it's a sensing function (returns a value)
	if func_name in ["frontIsClear", "leftIsClear", "rightIsClear", "goalReached", "onHazard", "hasKey"]:
		# These are handled in _evaluate_expression, not here
		_error("Sensing function '%s' must be used in an expression (if/while condition)" % func_name)
		return
	
	# Otherwise, call a user-defined function (statement context: ignore its return)
	await _invoke_function(call_node)

func _invoke_function(call_node: ASTNodes.CallNode):
	"""Run a user-defined function and return its return value. Used for both
	statement calls and calls embedded in expressions (e.g. x = f(), if f() > 1)."""
	var func_name = call_node.function_name
	if not func_name in user_functions:
		_error("Undefined function: %s" % func_name)
		return null

	var func_def = user_functions[func_name]

	# Evaluate arguments (an argument may itself contain a function call -> await)
	var args = []
	for arg in call_node.arguments:
		args.append(await _evaluate_expression(arg))

	if args.size() != func_def.parameters.size():
		_error("Function %s expects %d arguments, got %d" % [func_name, func_def.parameters.size(), args.size()])
		return null

	_push_scope()

	var params_dict = {}
	for i in range(func_def.parameters.size()):
		params_dict[func_def.parameters[i]] = args[i]

	current_call_depth += 1
	function_entered.emit(func_name, params_dict)

	for i in range(func_def.parameters.size()):
		_set_variable(func_def.parameters[i], args[i])

	# Save/restore caller return state so nested calls don't clobber each other.
	var previous_return_state = should_return
	var previous_return_value = return_value
	should_return = false
	return_value = null

	for statement in func_def.body:
		await _execute_statement(statement)
		if should_return:
			break

	var result = return_value
	should_return = previous_return_state
	return_value = previous_return_value

	current_call_depth -= 1
	function_exited.emit(func_name, result)

	_pop_scope()
	return result

func _execute_assignment(assign: ASTNodes.AssignmentNode):
	var value = await _evaluate_expression(assign.value)
	_assign_variable(assign.variable_name, value)
	# Emit signal for variable change
	variable_changed.emit(assign.variable_name, value)

func _execute_if(if_node: ASTNodes.IfNode):
	var condition = await _evaluate_expression(if_node.condition)
	
	if _is_truthy(condition):
		# Execute true branch
		await _execute_block(if_node.true_branch)
	else:
		# Check elif branches
		var executed = false
		for elif_branch in if_node.elif_branches:
			var elif_condition = await _evaluate_expression(elif_branch.condition)
			if _is_truthy(elif_condition):
				await _execute_block(elif_branch.body)
				executed = true
				break
		
		# Execute else branch if no elif was executed
		if not executed and if_node.false_branch.size() > 0:
			await _execute_block(if_node.false_branch)

func _execute_for(for_node: ASTNodes.ForNode):
	# Evaluate iterable
	var iterable = await _evaluate_expression(for_node.iterable)
	
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
	while _is_truthy(await _evaluate_expression(while_node.condition)):
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
		
		if not _is_truthy(await _evaluate_expression(do_while_node.condition)):
			break
		
		loop_count += 1
		if loop_count > max_iterations:
			_error("Do-while loop exceeded maximum iterations")
			break
	
	_pop_scope()

func _execute_return(return_node: ASTNodes.ReturnNode):
	if return_node.value:
		return_value = await _evaluate_expression(return_node.value)
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

	elif expr is ASTNodes.BooleanNode:
		return expr.value

	elif expr is ASTNodes.NullNode:
		return null

	elif expr is ASTNodes.IdentifierNode:
		return _get_variable(expr.name)
	
	elif expr is ASTNodes.BinaryOpNode:
		return await _evaluate_binary_op(expr)

	elif expr is ASTNodes.UnaryOpNode:
		return await _evaluate_unary_op(expr)

	elif expr is ASTNodes.RangeNode:
		return await _evaluate_range(expr)

	elif expr is ASTNodes.CallNode:
		var func_name = expr.function_name
		# Built-in sensing functions return a value directly
		if func_name in ["frontIsClear", "leftIsClear", "rightIsClear", "goalReached", "onHazard", "hasKey"]:
			return _evaluate_sensing_function(func_name)
		# Movement commands don't return a value
		if func_name in ["move", "turnRight", "turnLeft", "turnBack"]:
			_error("Command '%s()' doesn't return a value and can't be used in an expression" % func_name)
			return null
		# User-defined function used for its return value
		return await _invoke_function(expr)
	
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
		"hasKey":
			return current_player.has_key()
		_:
			_error("Unknown sensing function: %s" % func_name)
			return false

func _evaluate_binary_op(op: ASTNodes.BinaryOpNode):
	var left = await _evaluate_expression(op.left)
	var right = await _evaluate_expression(op.right)
	
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
			# GDScript's % is integer-only; use fmod when either side is a float.
			if left is float or right is float:
				return fmod(left, right)
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
	var operand = await _evaluate_expression(op.operand)
	
	match op.operator:
		"-":
			return -operand
		"not", "!":
			return not _is_truthy(operand)
		_:
			_error("Unknown unary operator: %s" % op.operator)
			return null

func _evaluate_range(range_node: ASTNodes.RangeNode):
	var start = await _evaluate_expression(range_node.start)
	var end = await _evaluate_expression(range_node.end)
	var step = 1

	if range_node.step:
		step = await _evaluate_expression(range_node.step)
	
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

func _set_variable(var_name: String, value):
	# Declare/bind in current scope (used for parameters and loop iterators)
	if scope_stack.size() > 0:
		scope_stack[scope_stack.size() - 1][var_name] = value
	else:
		global_scope[var_name] = value

func _assign_variable(var_name: String, value):
	# Assignment: update the variable where it already lives (innermost scope
	# that defines it, then global). Only create a new one in the current
	# scope if it does not exist anywhere. This lets a counter declared
	# before a loop be updated from inside the loop body.
	for i in range(scope_stack.size() - 1, -1, -1):
		if var_name in scope_stack[i]:
			scope_stack[i][var_name] = value
			return
	if var_name in global_scope:
		global_scope[var_name] = value
		return
	_set_variable(var_name, value)

func _get_variable(var_name: String):
	# Search from innermost to outermost scope
	for i in range(scope_stack.size() - 1, -1, -1):
		if var_name in scope_stack[i]:
			return scope_stack[i][var_name]
	
	# Check global scope
	if var_name in global_scope:
		return global_scope[var_name]
	
	_error("Undefined variable: %s" % var_name)
	return null

# ============================================
# Debug Control
# ============================================

func set_debug_manager(manager: DebugManager):
	"""Attach a debug manager to control execution"""
	debug_manager = manager
	Dbg.p("DEBUG [Interpreter]: Debug manager attached")

func set_execution_speed(speed: float):
	"""Set execution speed multiplier (0.25x to 5x)"""
	execution_speed = clamp(speed, 0.25, 5.0)
	Dbg.p("DEBUG [Interpreter]: Execution speed set to %.2fx" % execution_speed)

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
