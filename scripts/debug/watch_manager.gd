extends Node
class_name WatchManager

signal watch_added(expression: String)
signal watch_removed(expression: String)
signal watch_updated(expression: String, value, error: String)

var watches: Array[String] = []
var watch_values: Dictionary = {}  # expression -> value
var watch_errors: Dictionary = {}  # expression -> error message

func add_watch(expression: String):
	"""Add a watch expression"""
	if not watches.has(expression):
		watches.append(expression)
		watch_values[expression] = null
		watch_errors[expression] = ""
		watch_added.emit(expression)
		print("WATCH: Added '%s'" % expression)

func remove_watch(expression: String):
	"""Remove a watch expression"""
	var idx = watches.find(expression)
	if idx >= 0:
		watches.remove_at(idx)
		watch_values.erase(expression)
		watch_errors.erase(expression)
		watch_removed.emit(expression)
		print("WATCH: Removed '%s'" % expression)

func clear_watches():
	"""Remove all watch expressions"""
	watches.clear()
	watch_values.clear()
	watch_errors.clear()
	print("WATCH: All watches cleared")

func evaluate_watches(variables: Dictionary):
	"""Evaluate all watch expressions with current variables"""
	for expression in watches:
		var result = _evaluate_expression(expression, variables)
		watch_values[expression] = result.value
		watch_errors[expression] = result.error
		watch_updated.emit(expression, result.value, result.error)

func get_watch_value(expression: String):
	"""Get the current value of a watch expression"""
	return watch_values.get(expression, null)

func get_watch_error(expression: String) -> String:
	"""Get the error message for a watch expression"""
	return watch_errors.get(expression, "")

func _evaluate_expression(expression: String, variables: Dictionary) -> Dictionary:
	"""Evaluate a watch expression and return {value, error}"""
	var expr = Expression.new()
	var var_names = variables.keys()
	var var_values = variables.values()
	
	# Parse expression
	var parse_result = expr.parse(expression, var_names)
	if parse_result != OK:
		return {
			"value": null,
			"error": "Parse error: %s" % expr.get_error_text()
		}
	
	# Execute expression
	var value = expr.execute(var_values)
	if expr.has_execute_failed():
		return {
			"value": null,
			"error": "Execution error: %s" % expr.get_error_text()
		}
	
	return {
		"value": value,
		"error": ""
	}

func get_all_watches() -> Array:
	"""Get all watch expressions with their values"""
	var result = []
	for expression in watches:
		result.append({
			"expression": expression,
			"value": watch_values.get(expression, null),
			"error": watch_errors.get(expression, "")
		})
	return result
