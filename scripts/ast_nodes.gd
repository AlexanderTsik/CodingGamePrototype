extends RefCounted
class_name ASTNodes

# Base AST Node
class ASTNode:
	var node_type: String
	
	func _init(type: String):
		node_type = type
	
	func _to_string() -> String:
		return "ASTNode(%s)" % node_type

# ============================================
# Program Structure
# ============================================

class ProgramNode extends ASTNode:
	var statements: Array = []
	
	func _init():
		super._init("Program")
	
	func _to_string() -> String:
		return "Program(%d statements)" % statements.size()

class BlockNode extends ASTNode:
	var statements: Array = []
	
	func _init():
		super._init("Block")
	
	func _to_string() -> String:
		return "Block(%d statements)" % statements.size()

# ============================================
# Literals and Variables
# ============================================

class NumberNode extends ASTNode:
	var value
	
	func _init(val):
		super._init("Number")
		value = val
	
	func _to_string() -> String:
		return "Number(%s)" % str(value)

class StringNode extends ASTNode:
	var value: String
	
	func _init(val: String):
		super._init("String")
		value = val
	
	func _to_string() -> String:
		return "String(\"%s\")" % value

class IdentifierNode extends ASTNode:
	var name: String
	
	func _init(n: String):
		super._init("Identifier")
		name = n
	
	func _to_string() -> String:
		return "Identifier(%s)" % name

class AssignmentNode extends ASTNode:
	var variable_name: String
	var value  # Expression
	
	func _init(var_name: String, val):
		super._init("Assignment")
		variable_name = var_name
		value = val
	
	func _to_string() -> String:
		return "Assignment(%s = ...)" % variable_name

# ============================================
# Commands and Function Calls
# ============================================

class CommandNode extends ASTNode:
	var command_name: String
	var arguments: Array = []
	
	func _init(name: String, args: Array = []):
		super._init("Command")
		command_name = name
		arguments = args
	
	func _to_string() -> String:
		return "Command(%s)" % command_name

class CallNode extends ASTNode:
	var function_name: String
	var arguments: Array = []
	
	func _init(name: String, args: Array = []):
		super._init("Call")
		function_name = name
		arguments = args
	
	func _to_string() -> String:
		return "Call(%s)" % function_name

# ============================================
# Control Flow
# ============================================

class IfNode extends ASTNode:
	var condition  # Expression
	var true_branch: Array = []
	var elif_branches: Array = []  # Array of {condition, body}
	var false_branch: Array = []
	
	func _init(cond):
		super._init("If")
		condition = cond
	
	func _to_string() -> String:
		var elif_count = elif_branches.size()
		var has_else = false_branch.size() > 0
		return "If(condition, %d elifs, else=%s)" % [elif_count, str(has_else)]

class ForNode extends ASTNode:
	var iterator_var: String
	var iterable  # Expression (e.g., range call or array)
	var body: Array = []
	
	func _init(var_name: String, iter):
		super._init("For")
		iterator_var = var_name
		iterable = iter
	
	func _to_string() -> String:
		return "For(%s in ...)" % iterator_var

class WhileNode extends ASTNode:
	var condition  # Expression
	var body: Array = []
	
	func _init(cond):
		super._init("While")
		condition = cond
	
	func _to_string() -> String:
		return "While(condition)"

class DoWhileNode extends ASTNode:
	var condition  # Expression
	var body: Array = []
	
	func _init(cond):
		super._init("DoWhile")
		condition = cond
	
	func _to_string() -> String:
		return "DoWhile(condition)"

# ============================================
# Functions
# ============================================

class FunctionNode extends ASTNode:
	var function_name: String
	var parameters: Array = []
	var body: Array = []
	
	func _init(name: String):
		super._init("Function")
		function_name = name
	
	func _to_string() -> String:
		return "Function(%s, %d params)" % [function_name, parameters.size()]

class ReturnNode extends ASTNode:
	var value  # Expression (can be null)
	
	func _init(val = null):
		super._init("Return")
		value = val
	
	func _to_string() -> String:
		return "Return(%s)" % ("value" if value else "void")

# ============================================
# Expressions
# ============================================

class BinaryOpNode extends ASTNode:
	var left
	var operator: String
	var right
	
	func _init(l, op: String, r):
		super._init("BinaryOp")
		left = l
		operator = op
		right = r
	
	func _to_string() -> String:
		return "BinaryOp(%s)" % operator

class UnaryOpNode extends ASTNode:
	var operator: String
	var operand
	
	func _init(op: String, operand_node):
		super._init("UnaryOp")
		operator = op
		operand = operand_node
	
	func _to_string() -> String:
		return "UnaryOp(%s)" % operator

class RangeNode extends ASTNode:
	var start
	var end
	var step
	
	func _init(s, e, st = null):
		super._init("Range")
		start = s
		end = e
		step = st
	
	func _to_string() -> String:
		if step:
			return "Range(start..end, step)"
		return "Range(start..end)"
