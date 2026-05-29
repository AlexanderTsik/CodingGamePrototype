extends RefCounted
class_name TokenSystem

## Token Types Enumeration
enum TokenType {
	# Literals
	NUMBER,
	IDENTIFIER,
	STRING,
	
	# Keywords
	IF,
	ELSE,
	ELIF,
	FOR,
	WHILE,
	DO,
	IN,
	RANGE,
	FUNCTION,
	RETURN,
	TRUE,
	FALSE,
	NULL,
	
	# Operators
	EQUALS,           # ==
	NOT_EQUALS,       # !=
	LESS_THAN,        # <
	GREATER_THAN,     # >
	LESS_EQUAL,       # <=
	GREATER_EQUAL,    # >=
	ASSIGN,           # =
	PLUS,             # +
	MINUS,            # -
	MULTIPLY,         # *
	DIVIDE,           # /
	MODULO,           # %
	
	# Logical
	AND,
	OR,
	NOT,
	
	# Delimiters
	LEFT_PAREN,       # (
	RIGHT_PAREN,      # )
	LEFT_BRACE,       # {
	RIGHT_BRACE,      # }
	COMMA,            # ,
	NEWLINE,          # \n
	
	# Special
	EOF
}

## Token Class
class Token:
	var type: TokenType
	var value          # Can be String, int, float, bool, etc.
	var line: int
	var column: int
	
	func _init(t: TokenType, v, l: int = 0, c: int = 0):
		type = t
		value = v
		line = l
		column = c
	
	func _to_string() -> String:
		return "Token(%s, %s, line=%d, col=%d)" % [TokenType.keys()[type], str(value), line, column]
