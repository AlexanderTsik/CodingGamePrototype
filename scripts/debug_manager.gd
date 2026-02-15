extends Node
class_name DebugManager

signal step_requested
signal continue_requested
signal pause_requested

enum DebugMode {
	RUNNING,      # Normal execution
	PAUSED,       # Paused at current line
	STEP_OVER,    # Execute one statement
	STEP_INTO,    # Enter function calls
	STEP_OUT      # Exit current function
}

var current_mode: DebugMode = DebugMode.RUNNING
var breakpoints: Dictionary = {}  # line_number -> bool
var step_depth: int = 0  # Track function call depth for step_out
var current_call_depth: int = 0

func set_breakpoint(line: int, enabled: bool = true):
	"""Add or update a breakpoint at the specified line"""
	breakpoints[line] = enabled
	print("DEBUG: Breakpoint set at line %d (enabled: %s)" % [line, enabled])

func remove_breakpoint(line: int):
	"""Remove a breakpoint from the specified line"""
	breakpoints.erase(line)
	print("DEBUG: Breakpoint removed from line %d" % line)

func toggle_breakpoint(line: int):
	"""Toggle a breakpoint on/off at the specified line"""
	if breakpoints.has(line):
		breakpoints[line] = not breakpoints[line]
	else:
		breakpoints[line] = true
	print("DEBUG: Breakpoint toggled at line %d (enabled: %s)" % [line, breakpoints.get(line, false)])

func is_breakpoint(line: int) -> bool:
	"""Check if there's an enabled breakpoint at the specified line"""
	return breakpoints.get(line, false)

func has_breakpoint(line: int) -> bool:
	"""Check if a breakpoint exists at the specified line (enabled or disabled)"""
	return breakpoints.has(line)

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
