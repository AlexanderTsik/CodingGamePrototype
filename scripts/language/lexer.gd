extends RefCounted
class_name Lexer

const TokenType = TokenSystem.TokenType
const Token = TokenSystem.Token

var source: String
var position: int = 0
var line: int = 1
var column: int = 1
var tokens: Array = []
var errors: Array = []  # Collected error messages (empty = success)

# Keyword mapping
var keywords = {
	"if": TokenType.IF,
	"else": TokenType.ELSE,
	"elif": TokenType.ELIF,
	"for": TokenType.FOR,
	"while": TokenType.WHILE,
	"do": TokenType.DO,
	"in": TokenType.IN,
	"range": TokenType.RANGE,
	"function": TokenType.FUNCTION,
	"return": TokenType.RETURN,
	"and": TokenType.AND,
	"or": TokenType.OR,
	"not": TokenType.NOT,
	"true": TokenType.TRUE,
	"false": TokenType.FALSE,
	"null": TokenType.NULL
}

# Built-in commands (now treated as regular identifiers, checked at runtime)
# var commands = ["moveRight", "moveLeft", "moveUp", "moveDown"]

func tokenize(code: String) -> Array:
	source = code
	position = 0
	line = 1
	column = 1
	tokens = []
	errors = []
	
	while position < source.length():
		_skip_whitespace()
		if position >= source.length():
			break
		
		var ch = _current_char()
		
		# Handle comments
		if ch == '#':
			_skip_line()
			continue
		
		# Handle newlines
		if ch == '\n':
			tokens.append(Token.new(TokenType.NEWLINE, "\n", line, column))
			position += 1
			line += 1
			column = 1
			continue
		
		# Handle numbers
		if ch.is_valid_int() or (ch == '.' and _peek().is_valid_int()):
			tokens.append(_read_number())
			continue
		
		# Handle identifiers and keywords
		if ch.is_valid_identifier():
			tokens.append(_read_identifier())
			continue
		
		# Handle strings
		if ch == '"' or ch == "'":
			tokens.append(_read_string(ch))
			continue
		
		# Handle operators and delimiters
		match ch:
			'#':
				# Handle inline comments
				_skip_line()
			'(':
				_add_token(TokenType.LEFT_PAREN, ch)
			')':
				_add_token(TokenType.RIGHT_PAREN, ch)
			'{':
				_add_token(TokenType.LEFT_BRACE, ch)
			'}':
				_add_token(TokenType.RIGHT_BRACE, ch)
			',':
				_add_token(TokenType.COMMA, ch)
			'+':
				_add_token(TokenType.PLUS, ch)
			'-':
				_add_token(TokenType.MINUS, ch)
			'*':
				_add_token(TokenType.MULTIPLY, ch)
			'/':
				# Check for // comment
				if _peek() == '/':
					_skip_line()
				else:
					_add_token(TokenType.DIVIDE, ch)
			'%':
				_add_token(TokenType.MODULO, ch)
			'=':
				if _peek() == '=':
					position += 1
					column += 1
					_add_token(TokenType.EQUALS, "==")
				else:
					_add_token(TokenType.ASSIGN, ch)
			'!':
				if _peek() == '=':
					position += 1
					column += 1
					_add_token(TokenType.NOT_EQUALS, "!=")
				else:
					# Support ! as NOT operator (same as 'not' keyword)
					_add_token(TokenType.NOT, "!")
			'<':
				if _peek() == '=':
					position += 1
					column += 1
					_add_token(TokenType.LESS_EQUAL, "<=")
				else:
					_add_token(TokenType.LESS_THAN, ch)
			'>':
				if _peek() == '=':
					position += 1
					column += 1
					_add_token(TokenType.GREATER_EQUAL, ">=")
				else:
					_add_token(TokenType.GREATER_THAN, ch)
			_:
				_error("unexpected character '%s'" % ch)
				position += 1
				column += 1
	
	tokens.append(Token.new(TokenType.EOF, null, line, column))
	return tokens

func _error(message: String) -> void:
	var full := "Line %d, column %d: %s" % [line, column, message]
	errors.append(full)
	push_error("Lexer error — " + full)

func _current_char() -> String:
	if position < source.length():
		return source[position]
	return ""

func _peek(offset: int = 1) -> String:
	var pos = position + offset
	if pos < source.length():
		return source[pos]
	return ""

func _add_token(type: TokenType, value):
	tokens.append(Token.new(type, value, line, column))
	position += 1
	column += 1

func _skip_whitespace():
	while position < source.length() and source[position] in [' ', '\t', '\r']:
		if source[position] == '\t':
			column += 4
		else:
			column += 1
		position += 1

func _skip_line():
	while position < source.length() and source[position] != '\n':
		position += 1

func _read_number() -> Token:
	var start_pos = position
	var start_col = column
	var has_dot = false
	
	while position < source.length():
		var ch = source[position]
		if ch.is_valid_int():
			position += 1
			column += 1
		elif ch == '.' and not has_dot and position + 1 < source.length() and source[position + 1].is_valid_int():
			has_dot = true
			position += 1
			column += 1
		else:
			break
	
	var num_str = source.substr(start_pos, position - start_pos)
	var value
	if has_dot:
		value = float(num_str)
	else:
		value = int(num_str)
	return Token.new(TokenType.NUMBER, value, line, start_col)

func _read_identifier() -> Token:
	var start_pos = position
	var start_col = column
	
	while position < source.length():
		var ch = source[position]
		if ch.is_valid_identifier() or ch.is_valid_int():
			position += 1
			column += 1
		else:
			break
	
	var identifier = source.substr(start_pos, position - start_pos)
	
	# Check if it's a keyword
	if identifier in keywords:
		return Token.new(keywords[identifier], identifier, line, start_col)
	
	# All non-keywords are identifiers (built-in commands are checked at runtime)
	return Token.new(TokenType.IDENTIFIER, identifier, line, start_col)

func _read_string(quote_char: String) -> Token:
	var start_col = column
	position += 1  # Skip opening quote
	column += 1
	
	var result = ""
	
	while position < source.length() and source[position] != quote_char:
		var ch = source[position]
		
		# Handle escape sequences
		if ch == '\\' and position + 1 < source.length():
			position += 1
			column += 1
			var next_char = source[position]
			match next_char:
				'n':
					result += '\n'
				't':
					result += '\t'
				'\\':
					result += '\\'
				'"':
					result += '"'
				"'":
					result += "'"
				_:
					result += next_char
			position += 1
			column += 1
		else:
			result += ch
			position += 1
			column += 1
	
	if position >= source.length():
		_error("unterminated string")
		return Token.new(TokenType.STRING, result, line, start_col)
	
	position += 1  # Skip closing quote
	column += 1
	
	return Token.new(TokenType.STRING, result, line, start_col)
