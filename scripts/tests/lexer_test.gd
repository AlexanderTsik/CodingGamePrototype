extends Node

# Simple test script for the Lexer
# Run this scene to test tokenization

func _ready():
	print("=== Lexer Test ===\n")
	
	# Test 1: Basic commands
	_test_lexer("Basic Commands", """
moveRight()
moveLeft()
moveUp()
""")
	
	# Test 2: Variables and expressions
	_test_lexer("Variables", """
x = 5
y = x + 10
""")
	
	# Test 3: If statement
	_test_lexer("If Statement", """
if (x > 5) {
	moveRight()
}
""")
	
	# Test 4: For loop
	_test_lexer("For Loop", """
for (i in range(5)) {
	moveRight()
}
""")
	
	# Test 5: While loop
	_test_lexer("While Loop", """
while (x < 10) {
	moveUp()
	x = x + 1
}
""")
	
	# Test 6: Function definition
	_test_lexer("Function", """
function goForward() {
	moveRight()
	moveRight()
}
""")
	
	# Test 7: Complex nested
	_test_lexer("Complex Nested", """
x = 0
for (i in range(3)) {
	if (x == 1) {
		moveRight()
	} else {
		moveLeft()
	}
	x = x + 1
}
""")
	
	print("\n=== All Tests Complete ===")

func _test_lexer(test_name: String, code: String):
	print("\n--- Test: %s ---" % test_name)
	print("Code:\n%s" % code)
	
	var lexer = Lexer.new()
	var tokens = lexer.tokenize(code)
	
	print("\nTokens:")
	for token in tokens:
		if token.type != TokenSystem.TokenType.NEWLINE and token.type != TokenSystem.TokenType.EOF:
			print("  %s" % token)
	
	print("Total tokens: %d" % tokens.size())
