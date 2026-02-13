extends Node

# Parser test script
# Run this scene to test AST generation

func _ready():
	print("=== Parser Test ===\n")
	
	# Test 1: Simple commands
	_test_parser("Simple Commands", """
moveRight()
moveLeft()
""")
	
	# Test 2: Variables
	_test_parser("Variables", """
x = 5
y = x + 10
z = x * 2 + y
""")
	
	# Test 3: If statement
	_test_parser("If Statement", """
x = 5
if (x > 3) {
	moveRight()
} else {
	moveLeft()
}
""")
	
	# Test 4: For loop
	_test_parser("For Loop", """
for (i in range(5)) {
	moveRight()
}
""")
	
	# Test 5: While loop
	_test_parser("While Loop", """
x = 0
while (x < 3) {
	moveUp()
	x = x + 1
}
""")
	
	# Test 6: Do-while loop
	_test_parser("Do-While Loop", """
x = 0
do {
	moveDown()
	x = x + 1
} while (x < 3)
""")
	
	# Test 7: Function
	_test_parser("Function Definition", """
function goForward() {
	moveRight()
	moveRight()
}

goForward()
""")
	
	# Test 8: Nested control flow
	_test_parser("Nested Control Flow", """
for (i in range(3)) {
	if (i == 1) {
		moveRight()
	} else {
		moveLeft()
	}
}
""")
	
	# Test 9: Complex expression
	_test_parser("Complex Expression", """
x = 5
y = 10
if (x > 3 and y < 20 or x == 5) {
	moveUp()
}
""")
	
	print("\n=== All Parser Tests Complete ===")

func _test_parser(test_name: String, code: String):
	print("\n--- Test: %s ---" % test_name)
	print("Code:\n%s" % code)
	
	# Tokenize
	var lexer = Lexer.new()
	var tokens = lexer.tokenize(code)
	
	# Parse
	var parser = Parser.new()
	var ast = parser.parse(tokens)
	
	print("\nAST:")
	_print_ast(ast, 0)
	
	print("\nStatements: %d" % ast.statements.size())

func _print_ast(node, indent: int):
	var indent_str = "  ".repeat(indent)
	
	if node == null:
		print("%s<null>" % indent_str)
		return
	
	print("%s%s" % [indent_str, node])
	
	# Print children based on node type
	if node is ASTNodes.ProgramNode:
		for stmt in node.statements:
			_print_ast(stmt, indent + 1)
	
	elif node is ASTNodes.IfNode:
		print("%sCondition:" % indent_str)
		_print_ast(node.condition, indent + 2)
		print("%sTrue branch:" % indent_str)
		for stmt in node.true_branch:
			_print_ast(stmt, indent + 2)
		if node.elif_branches.size() > 0:
			for elif_branch in node.elif_branches:
				print("%sElif condition:" % indent_str)
				_print_ast(elif_branch.condition, indent + 2)
				print("%sElif body:" % indent_str)
				for stmt in elif_branch.body:
					_print_ast(stmt, indent + 2)
		if node.false_branch.size() > 0:
			print("%sFalse branch:" % indent_str)
			for stmt in node.false_branch:
				_print_ast(stmt, indent + 2)
	
	elif node is ASTNodes.ForNode:
		print("%sIterator: %s" % [indent_str, node.iterator_var])
		print("%sIterable:" % indent_str)
		_print_ast(node.iterable, indent + 2)
		print("%sBody:" % indent_str)
		for stmt in node.body:
			_print_ast(stmt, indent + 2)
	
	elif node is ASTNodes.WhileNode or node is ASTNodes.DoWhileNode:
		print("%sCondition:" % indent_str)
		_print_ast(node.condition, indent + 2)
		print("%sBody:" % indent_str)
		for stmt in node.body:
			_print_ast(stmt, indent + 2)
	
	elif node is ASTNodes.FunctionNode:
		print("%sParameters: %s" % [indent_str, str(node.parameters)])
		print("%sBody:" % indent_str)
		for stmt in node.body:
			_print_ast(stmt, indent + 2)
	
	elif node is ASTNodes.AssignmentNode:
		print("%sVariable: %s" % [indent_str, node.variable_name])
		print("%sValue:" % indent_str)
		_print_ast(node.value, indent + 2)
	
	elif node is ASTNodes.BinaryOpNode:
		print("%sOperator: %s" % [indent_str, node.operator])
		print("%sLeft:" % indent_str)
		_print_ast(node.left, indent + 2)
		print("%sRight:" % indent_str)
		_print_ast(node.right, indent + 2)
	
	elif node is ASTNodes.UnaryOpNode:
		print("%sOperator: %s" % [indent_str, node.operator])
		print("%sOperand:" % indent_str)
		_print_ast(node.operand, indent + 2)
	
	elif node is ASTNodes.CallNode or node is ASTNodes.CommandNode:
		if node.arguments.size() > 0:
			print("%sArguments:" % indent_str)
			for arg in node.arguments:
				_print_ast(arg, indent + 2)
	
	elif node is ASTNodes.RangeNode:
		print("%sStart:" % indent_str)
		_print_ast(node.start, indent + 2)
		print("%sEnd:" % indent_str)
		_print_ast(node.end, indent + 2)
		if node.step:
			print("%sStep:" % indent_str)
			_print_ast(node.step, indent + 2)
