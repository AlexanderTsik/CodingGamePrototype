extends "res://test/ld_test.gd"

func _parse(code: String):
	return Parser.new().parse(Lexer.new().tokenize(code))

func run() -> void:
	await tree.process_frame

	section("assignment + for loop")
	var ast = _parse("x = 5\nfor (i in range(3)) { move() }")
	assert_not_null(ast, "ast not null")
	assert_eq(ast.statements.size(), 2, "two top-level statements")
	assert_true(ast.statements[0] is ASTNodes.AssignmentNode, "first is assignment")
	assert_true(ast.statements[1] is ASTNodes.ForNode, "second is for")

	section("call vs assignment disambiguation")
	var ast2 = _parse("move()\nx = 1")
	assert_true(ast2.statements[0] is ASTNodes.CallNode, "move() is a call")
	assert_true(ast2.statements[1] is ASTNodes.AssignmentNode, "x = 1 is assignment")

	section("if / elif / else")
	var ast3 = _parse("if (x > 1) { move() } elif (x < 0) { turnLeft() } else { turnRight() }")
	var if_node = ast3.statements[0]
	assert_true(if_node is ASTNodes.IfNode, "is an if node")
	assert_eq(if_node.elif_branches.size(), 1, "one elif branch")
	assert_true(if_node.false_branch.size() > 0, "has an else branch")

	section("operator precedence: 2 + 3 * 4 groups as 2 + (3*4)")
	var ast4 = _parse("x = 2 + 3 * 4")
	var rhs = ast4.statements[0].value
	assert_true(rhs is ASTNodes.BinaryOpNode, "rhs is binary op")
	assert_eq(rhs.operator, "+", "top operator is +")
	assert_true(rhs.right is ASTNodes.BinaryOpNode, "right operand is the * group")
	assert_eq(rhs.right.operator, "*", "nested operator is *")

	section("valid code produces no parser errors")
	var p = Parser.new()
	p.parse(Lexer.new().tokenize("function f(n) { for (i in range(n)) { move() } }\nf(3)"))
	assert_true(p.errors.is_empty(), "no errors on valid function")

	section("malformed code is reported")
	var p2 = Parser.new()
	p2.parse(Lexer.new().tokenize("if (x > 5 { move() }"))
	assert_false(p2.errors.is_empty(), "missing ')' recorded")
