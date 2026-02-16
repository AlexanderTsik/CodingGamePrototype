extends Node
class_name DebugManager

signal step_requested
signal continue_requested
signal pause_requested
signal breakpoint_hit(line: int)

enum DebugMode {
	RUNNING,      # Normal execution
	PAUSED,       # Paused at current line
	STEP_OVER,    # Execute one statement
	STEP_INTO,    # Enter function calls
	STEP_OUT      # Exit current function
}

# Breakpoint data class
class BreakpointData:
	var enabled: bool = true
	var condition: String = ""  # GDScript expression to evaluate
	var hit_count: int = 0
	var hit_condition: String = ""  # e.g., ">5", "==3", "%2==0"
	var log_message: String = ""  # Optional log message when hit
	
	func _init(enable: bool = true, cond: String = "", hit_cond: String = ""):
		enabled = enable
		condition = cond
		hit_condition = hit_cond

var current_mode: DebugMode = DebugMode.RUNNING
var breakpoints: Dictionary = {}  # line_number -> BreakpointData
var step_depth: int = 0  # Track function call depth for step_out
var current_call_depth: int = 0

func set_breakpoint(line: int, enabled: bool = true, condition: String = "", hit_condition: String = ""):
	"""Add or update a breakpoint at the specified line"""
	if not breakpoints.has(line):
		breakpoints[line] = BreakpointData.new(enabled, condition, hit_condition)
	else:
		var bp = breakpoints[line]
		bp.enabled = enabled
		if condition != "":
			bp.condition = condition
		if hit_condition != "":
			bp.hit_condition = hit_condition
	print("DEBUG: Breakpoint set at line %d (enabled: %s, condition: '%s')" % [line, enabled, condition])

func remove_breakpoint(line: int):
	"""Remove a breakpoint from the specified line"""
	breakpoints.erase(line)
	print("DEBUG: Breakpoint removed from line %d" % line)

func toggle_breakpoint(line: int):
	"""Toggle a breakpoint on/off at the specified line"""
	if breakpoints.has(line):
		var bp = breakpoints[line]
		bp.enabled = not bp.enabled
	else:
		breakpoints[line] = BreakpointData.new()
	print("DEBUG: Breakpoint toggled at line %d (enabled: %s)" % [line, is_breakpoint(line)])

func is_breakpoint(line: int) -> bool:
	"""Check if there's an enabled breakpoint at the specified line"""
	if not breakpoints.has(line):
		return false
	return breakpoints[line].enabled

func has_breakpoint(line: int) -> bool:
	"""Check if a breakpoint exists at the specified line (enabled or disabled)"""
	return breakpoints.has(line)

func get_breakpoint_data(line: int) -> BreakpointData:
	"""Get breakpoint data for a specific line"""
	return breakpoints.get(line, null)

func should_break_at(line: int, variables: Dictionary) -> bool:
	"""Check if execution should break at this line based on conditions"""
	if not breakpoints.has(line):
		return false
	
	var bp = breakpoints[line]
	if not bp.enabled:
		return false
	
	# Increment hit count
	bp.hit_count += 1
	
	# Check hit condition (e.g., ">5", "==3", "%2==0")
	if bp.hit_condition != "":
		if not _evaluate_hit_condition(bp.hit_count, bp.hit_condition):
			return false
	
	# Check conditional expression
	if bp.condition != "":
		if not _evaluate_condition(bp.condition, variables):
			return false
	
	# Emit signal
	breakpoint_hit.emit(line)
	
	# Log message if set
	if bp.log_message != "":
		print("BREAKPOINT LOG [Line %d]: %s" % [line, bp.log_message])
	
	return true

func _evaluate_hit_condition(hit_count: int, condition: String) -> bool:
	"""Evaluate hit count condition (e.g., '>5', '==3', '%2==0')"""
	var expr = Expression.new()
	var result = expr.parse(condition.replace("n", str(hit_count)))
	if result != OK:
		print("ERROR: Invalid hit condition: %s" % condition)
		return true  # Break anyway if invalid
	
	return expr.execute()

func _evaluate_condition(condition: String, variables: Dictionary) -> bool:
	"""Evaluate breakpoint condition using available variables"""
	var expr = Expression.new()
	var var_names = variables.keys()
	var var_values = variables.values()
	
	var result = expr.parse(condition, var_names)
	if result != OK:
		print("ERROR: Invalid breakpoint condition: %s" % condition)
		return true  # Break anyway if invalid
	
	var value = expr.execute(var_values)
	if expr.has_execute_failed():
		print("ERROR: Failed to evaluate condition: %s" % condition)
		return true
	
	return bool(value)

func get_all_breakpoints() -> Array:
	"""Get all breakpoints as array of dictionaries"""
	var result = []
	for line in breakpoints.keys():
		var bp = breakpoints[line]
		result.append({
			"line": line,
			"enabled": bp.enabled,
			"condition": bp.condition,
			"hit_count": bp.hit_count,
			"hit_condition": bp.hit_condition
		})
	return result

func pause():
	"""Pause execution"""
	current_mode = DebugMode.PAUSED
	pause_requested.emit()
	print("DEBUG: Execution paused")

func resume():
	"""Resume normal execution"""
	current_mode = DebugMode.RUNNING
	continue_requested.emit()
	print("DEBUG: Execution resumed")

func step_over():
	"""Execute one statement (don't enter functions)"""
	current_mode = DebugMode.STEP_OVER
	step_requested.emit()
	print("DEBUG: Step over requested")

func step_into():
	"""Execute one statement (enter functions)"""
	current_mode = DebugMode.STEP_INTO
	step_requested.emit()
	print("DEBUG: Step into requested")

func step_out():
	"""Continue until current function returns"""
	current_mode = DebugMode.STEP_OUT
	step_depth = current_call_depth
	step_requested.emit()
	print("DEBUG: Step out requested (depth: %d)" % step_depth)

func should_pause_at_line(line: int, call_depth: int) -> bool:
	"""Check if execution should pause at the given line"""
	current_call_depth = call_depth
	
	# Check for breakpoints
	if is_breakpoint(line):
		return true
	
	# Check debug mode
	match current_mode:
		DebugMode.PAUSED:
			return true
		
		DebugMode.STEP_OVER:
			# Pause at next statement at same or higher level
			return true
		
		DebugMode.STEP_INTO:
			# Pause at next statement regardless of depth
			return true
		
		DebugMode.STEP_OUT:
			# Pause when we've returned to a lower depth
			if call_depth < step_depth:
				return true
			return false
		
		DebugMode.RUNNING:
			return false
	
	return false

func reset():
	"""Reset debug state for new execution"""
	current_mode = DebugMode.RUNNING
	current_call_depth = 0
	step_depth = 0
	print("DEBUG: Debug manager reset")
