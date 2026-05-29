extends RefCounted
class_name Parser

const TokenType = TokenSystem.TokenType
const Token = TokenSystem.Token

var tokens: Array
var current: int = 0
var functions: Dictionary = {}
var errors: Array = []  # Collected error messages (empty = success)

func parse(token_list: Array) -> ASTNodes.ProgramNode:
	tokens = token_list
	current = 0
	functions = {}
	errors = []
	
	var program = ASTNodes.ProgramNode.new()
	
	while not _is_at_end():
		_skip_newlines()
		if _is_at_end():
			break
		
		var stmt = _parse_statement()
		if stmt:
			program.statements.append(stmt)
	
	return program

# ============================================
# Statement Parsing
# ============================================

func _parse_statement():
	_skip_newlines()
	
	if _is_at_end():
		return null
	
	var token = _peek()
	
	match token.type:
		TokenType.IF:
			return _parse_if_statement()
		TokenType.FOR:
			return _parse_for_loop()
		TokenType.WHILE:
			return _parse_while_loop()
		TokenType.DO:
			return _parse_do_while_loop()
		TokenType.FUNCTION:
			return _parse_function_definition()
		TokenType.RETURN:
			return _parse_return_statement()
		TokenType.IDENTIFIER:
			# Could be function call or assignment
			if _peek_ahead(1).type == TokenType.LEFT_PAREN:
				return _parse_function_call()
			else:
				return _parse_assignment()
		TokenType.LEFT_BRACE:
			return _parse_block()
		_:
			_error("Unexpected token: %s" % str(token.value))
			_advance()
			return null

func _parse_if_statement() -> ASTNodes.IfNode:
	var if_token = _consume(TokenType.IF, "Expected 'if'")
	_consume(TokenType.LEFT_PAREN, "Expected '(' after 'if'")
	
	var condition = _parse_expression()
	
	_consume(TokenType.RIGHT_PAREN, "Expected ')' after condition")
	_consume(TokenType.LEFT_BRACE, "Expected '{' after if condition")
	
	var if_node = ASTNodes.IfNode.new(condition, if_token.line)
	if_node.true_branch = _parse_block_body()
	
	_consume(TokenType.RIGHT_BRACE, "Expected '}' after if body")
	_skip_newlines()
	
	# Handle elif
	while _match(TokenType.ELIF):
		_consume(TokenType.LEFT_PAREN, "Expected '(' after 'elif'")
		var elif_condition = _parse_expression()
		_consume(TokenType.RIGHT_PAREN, "Expected ')' after elif condition")
		_consume(TokenType.LEFT_BRACE, "Expected '{' after elif condition")
		
		var elif_body = _parse_block_body()
		if_node.elif_branches.append({
			"condition": elif_condition,
			"body": elif_body
		})
		
		_consume(TokenType.RIGHT_BRACE, "Expected '}' after elif body")
		_skip_newlines()
	
	# Handle else
	if _match(TokenType.ELSE):
		_consume(TokenType.LEFT_BRACE, "Expected '{' after 'else'")
		if_node.false_branch = _parse_block_body()
		_consume(TokenType.RIGHT_BRACE, "Expected '}' after else body")
	
	return if_node

func _parse_for_loop() -> ASTNodes.ForNode:
	var for_token = _consume(TokenType.FOR, "Expected 'for'")
	_consume(TokenType.LEFT_PAREN, "Expected '(' after 'for'")
	
	var iterator = _consume(TokenType.IDENTIFIER, "Expected iterator variable")
	var iterator_name = iterator.value
	
	_consume(TokenType.IN, "Expected 'in' after iterator variable")
	
	var iterable = _parse_expression()
	
	_consume(TokenType.RIGHT_PAREN, "Expected ')' after for declaration")
	_consume(TokenType.LEFT_BRACE, "Expected '{' after for declaration")
	
	var for_node = ASTNodes.ForNode.new(iterator_name, iterable, for_token.line)
	for_node.body = _parse_block_body()
	
	_consume(TokenType.RIGHT_BRACE, "Expected '}' after for body")
	
	return for_node

func _parse_while_loop() -> ASTNodes.WhileNode:
	var while_token = _consume(TokenType.WHILE, "Expected 'while'")
	_consume(TokenType.LEFT_PAREN, "Expected '(' after 'while'")
	
	var condition = _parse_expression()
	
	_consume(TokenType.RIGHT_PAREN, "Expected ')' after while condition")
	_consume(TokenType.LEFT_BRACE, "Expected '{' after while condition")
	
	var while_node = ASTNodes.WhileNode.new(condition, while_token.line)
	while_node.body = _parse_block_body()
	
	_consume(TokenType.RIGHT_BRACE, "Expected '}' after while body")
	
	return while_node

func _parse_do_while_loop() -> ASTNodes.DoWhileNode:
	var do_token = _consume(TokenType.DO, "Expected 'do'")
	_consume(TokenType.LEFT_BRACE, "Expected '{' after 'do'")
	
	var do_while_node = ASTNodes.DoWhileNode.new(null, do_token.line)
	do_while_node.body = _parse_block_body()
	
	_consume(TokenType.RIGHT_BRACE, "Expected '}' after do body")
	_skip_newlines()
	_consume(TokenType.WHILE, "Expected 'while' after do body")
	_consume(TokenType.LEFT_PAREN, "Expected '(' after 'while'")
	
	do_while_node.condition = _parse_expression()
	
	_consume(TokenType.RIGHT_PAREN, "Expected ')' after while condition")
	
	return do_while_node

func _parse_function_definition() -> ASTNodes.FunctionNode:
	var func_token = _consume(TokenType.FUNCTION, "Expected 'function'")
	
	var func_name_token = _consume(TokenType.IDENTIFIER, "Expected function name")
	var func_name = func_name_token.value
	
	_consume(TokenType.LEFT_PAREN, "Expected '(' after function name")
	
	var params = []
	if not _check(TokenType.RIGHT_PAREN):
		params.append(_consume(TokenType.IDENTIFIER, "Expected parameter name").value)
		while _match(TokenType.COMMA):
			params.append(_consume(TokenType.IDENTIFIER, "Expected parameter name").value)
	
	_consume(TokenType.RIGHT_PAREN, "Expected ')' after parameters")
	_consume(TokenType.LEFT_BRACE, "Expected '{' after function signature")
	
	var func_node = ASTNodes.FunctionNode.new(func_name, func_token.line)
	func_node.parameters = params
	func_node.body = _parse_block_body()
	
	_consume(TokenType.RIGHT_BRACE, "Expected '}' after function body")
	
	# Store function definition
	functions[func_name] = func_node
	
	return func_node

func _parse_return_statement() -> ASTNodes.ReturnNode:
	var return_token = _consume(TokenType.RETURN, "Expected 'return'")
	
	# Check if there's a return value
	if _check(TokenType.NEWLINE) or _check(TokenType.RIGHT_BRACE):
		return ASTNodes.ReturnNode.new(null, return_token.line)
	
	var value = _parse_expression()
	return ASTNodes.ReturnNode.new(value, return_token.line)

func _parse_function_call() -> ASTNodes.CallNode:
	var func_name_token = _consume(TokenType.IDENTIFIER, "Expected function name")
	var func_name = func_name_token.value
	
	_consume(TokenType.LEFT_PAREN, "Expected '(' after function name")
	
	var args = []
	if not _check(TokenType.RIGHT_PAREN):
		args.append(_parse_expression())
		while _match(TokenType.COMMA):
			args.append(_parse_expression())
	
	_consume(TokenType.RIGHT_PAREN, "Expected ')' after function arguments")
	
	return ASTNodes.CallNode.new(func_name, args, func_name_token.line)

func _parse_assignment() -> ASTNodes.AssignmentNode:
	var var_name_token = _consume(TokenType.IDENTIFIER, "Expected variable name")
	var var_name = var_name_token.value
	
	_consume(TokenType.ASSIGN, "Expected '=' in assignment")
	
	var value = _parse_expression()
	
	return ASTNodes.AssignmentNode.new(var_name, value, var_name_token.line)

func _parse_block() -> ASTNodes.BlockNode:
	_consume(TokenType.LEFT_BRACE, "Expected '{'")
	
	var block = ASTNodes.BlockNode.new()
	block.statements = _parse_block_body()
	
	_consume(TokenType.RIGHT_BRACE, "Expected '}'")
	
	return block

func _parse_block_body() -> Array:
	var statements = []
	
	while not _check(TokenType.RIGHT_BRACE) and not _is_at_end():
		_skip_newlines()
		if _check(TokenType.RIGHT_BRACE):
			break
		
		var stmt = _parse_statement()
		if stmt:
			statements.append(stmt)
	
	return statements

# ============================================
# Expression Parsing (Precedence Climbing)
# ============================================

func _parse_expression():
	return _parse_logical_or()

func _parse_logical_or():
	var left = _parse_logical_and()
	
	while _match(TokenType.OR):
		var op = "or"
		var right = _parse_logical_and()
		left = ASTNodes.BinaryOpNode.new(left, op, right)
	
	return left

func _parse_logical_and():
	var left = _parse_equality()
	
	while _match(TokenType.AND):
		var op = "and"
		var right = _parse_equality()
		left = ASTNodes.BinaryOpNode.new(left, op, right)
	
	return left

func _parse_equality():
	var left = _parse_comparison()
	
	while _match(TokenType.EQUALS) or _match(TokenType.NOT_EQUALS):
		var op = _previous().value
		var right = _parse_comparison()
		left = ASTNodes.BinaryOpNode.new(left, op, right)
	
	return left

func _parse_comparison():
	var left = _parse_addition()
	
	while _match(TokenType.LESS_THAN) or _match(TokenType.GREATER_THAN) or \
	      _match(TokenType.LESS_EQUAL) or _match(TokenType.GREATER_EQUAL):
		var op = _previous().value
		var right = _parse_addition()
		left = ASTNodes.BinaryOpNode.new(left, op, right)
	
	return left

func _parse_addition():
	var left = _parse_multiplication()
	
	while _match(TokenType.PLUS) or _match(TokenType.MINUS):
		var op = _previous().value
		var right = _parse_multiplication()
		left = ASTNodes.BinaryOpNode.new(left, op, right)
	
	return left

func _parse_multiplication():
	var left = _parse_unary()
	
	while _match(TokenType.MULTIPLY) or _match(TokenType.DIVIDE) or _match(TokenType.MODULO):
		var op = _previous().value
		var right = _parse_unary()
		left = ASTNodes.BinaryOpNode.new(left, op, right)
	
	return left

func _parse_unary():
	if _match(TokenType.NOT) or _match(TokenType.MINUS):
		var op = _previous().value
		var operand = _parse_unary()
		return ASTNodes.UnaryOpNode.new(op, operand)
	
	return _parse_primary()

func _parse_primary():
	# Number literal
	if _match(TokenType.NUMBER):
		return ASTNodes.NumberNode.new(_previous().value)

	# Boolean / null literals
	if _match(TokenType.TRUE):
		return ASTNodes.BooleanNode.new(true)
	if _match(TokenType.FALSE):
		return ASTNodes.BooleanNode.new(false)
	if _match(TokenType.NULL):
		return ASTNodes.NullNode.new()
	
	# String literal
	if _match(TokenType.STRING):
		return ASTNodes.StringNode.new(_previous().value)
	
	# Range function
	if _match(TokenType.RANGE):
		_consume(TokenType.LEFT_PAREN, "Expected '(' after 'range'")
		var start = _parse_expression()
		
		var end = null
		var step = null
		
		if _match(TokenType.COMMA):
			end = _parse_expression()
			if _match(TokenType.COMMA):
				step = _parse_expression()
		
		_consume(TokenType.RIGHT_PAREN, "Expected ')' after range")
		
		# range(n) means range(0, n)
		if end == null:
			end = start
			start = ASTNodes.NumberNode.new(0)
		
		return ASTNodes.RangeNode.new(start, end, step)
	
	# Identifier or function call
	if _check(TokenType.IDENTIFIER):
		var name_token = _peek()
		if _peek_ahead(1).type == TokenType.LEFT_PAREN:
			return _parse_function_call()
		else:
			_advance()
			return ASTNodes.IdentifierNode.new(name_token.value)
	
	# Parenthesized expression
	if _match(TokenType.LEFT_PAREN):
		var expr = _parse_expression()
		_consume(TokenType.RIGHT_PAREN, "Expected ')' after expression")
		return expr
	
	_error("Unexpected token in expression: %s" % str(_peek().value))
	_advance()
	return null

# ============================================
# Helper Methods
# ============================================

func _match(type: TokenType) -> bool:
	if _check(type):
		_advance()
		return true
	return false

func _check(type: TokenType) -> bool:
	if _is_at_end():
		return false
	return _peek().type == type

func _advance() -> Token:
	if not _is_at_end():
		current += 1
	return _previous()

func _is_at_end() -> bool:
	return current >= tokens.size() or _peek().type == TokenType.EOF

func _peek() -> Token:
	if current < tokens.size():
		return tokens[current]
	return tokens[tokens.size() - 1]  # Return EOF

func _peek_ahead(offset: int) -> Token:
	var pos = current + offset
	if pos < tokens.size():
		return tokens[pos]
	return tokens[tokens.size() - 1]  # Return EOF

func _previous() -> Token:
	return tokens[current - 1]

func _consume(type: TokenType, message: String) -> Token:
	if _check(type):
		return _advance()
	
	_error(message + " (got %s)" % str(_peek().value))
	return _peek()

func _skip_newlines():
	while _match(TokenType.NEWLINE):
		pass

func _error(message: String):
	var token = _peek()
	var full := "Line %d, column %d: %s" % [token.line, token.column, message]
	errors.append(full)
	push_error("Parse error — " + full)
