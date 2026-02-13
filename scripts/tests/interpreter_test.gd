extends Node

# Interpreter test script
# This tests execution without a real player (using a mock)

# Mock player for testing
class MockPlayer extends Node2D:
	var position_log: Array = []
	var start_position: Vector2 = Vector2.ZERO
	const GRID_SIZE = 64
	
	func _init():
		position = start_position
	
	func reset_position():
		position = start_position
		position_log.clear()
	
	func move_right():
		position += Vector2(GRID_SIZE, 0)
		position_log.append("moveRight -> %s" % position)
		print("  [Player] moveRight -> %s" % position)
	
	func move_left():
		position += Vector2(-GRID_SIZE, 0)
		position_log.append("moveLeft -> %s" % position)
		print("  [Player] moveLeft -> %s" % position)
	
	func move_up():
		position += Vector2(0, -GRID_SIZE)
		position_log.append("moveUp -> %s" % position)
		print("  [Player] moveUp -> %s" % position)
	
	func move_down():
		position += Vector2(0, GRID_SIZE)
		position_log.append("moveDown -> %s" % position)
		print("  [Player] moveDown -> %s" % position)

var mock_player: MockPlayer
var interpreter: Interpreter

func _ready():
	print("=== Interpreter Test ===\n")
	
	mock_player = MockPlayer.new()
	add_child(mock_player)
	
	interpreter = Interpreter.new()
	add_child(interpreter)
	
	interpreter.execution_complete.connect(_on_test_complete)
	interpreter.execution_error.connect(_on_test_error)
	
	await _run_tests()
	
	print("\n=== All Interpreter Tests Complete ===")

func _run_tests():
	# Test 1: Simple commands
	await _test_code("Simple Commands", """
moveRight()
moveLeft()
moveUp()
""")
	
	# Test 2: Variables and expressions
	await _test_code("Variables and Expressions", """
x = 5
y = 10
z = x + y
""")
	
	# Test 3: If statement
	await _test_code("If Statement", """
x = 10
if (x > 5) {
	moveRight()
	moveRight()
}
""")
	
	# Test 4: If-else
	await _test_code("If-Else", """
x = 3
if (x > 5) {
	moveRight()
} else {
	moveLeft()
}
""")
	
	# Test 5: Elif
	await _test_code("If-Elif-Else", """
x = 5
if (x < 3) {
	moveLeft()
} elif (x == 5) {
	moveUp()
} else {
	moveDown()
}
""")
	
	# Test 6: For loop with range
	await _test_code("For Loop with Range", """
for (i in range(3)) {
	moveRight()
}
""")
	
	# Test 7: While loop
	await _test_code("While Loop", """
x = 0
while (x < 3) {
	moveUp()
	x = x + 1
}
""")
	
	# Test 8: Do-while loop
	await _test_code("Do-While Loop", """
x = 0
do {
	moveDown()
	x = x + 1
} while (x < 2)
""")
	
	# Test 9: Function definition and call
	await _test_code("Function", """
function square() {
	moveRight()
	moveDown()
	moveLeft()
	moveUp()
}

square()
""")
	
	# Test 10: Nested control flow
	await _test_code("Nested For + If", """
for (i in range(3)) {
	if (i == 1) {
		moveRight()
	} else {
		moveLeft()
	}
}
""")
	
	# Test 11: Complex expressions
	await _test_code("Complex Expressions", """
x = 5
y = 10
if (x > 3 and y < 20) {
	moveUp()
}
if (x == 5 or y == 100) {
	moveDown()
}
""")
	
	# Test 12: Arithmetic
	await _test_code("Arithmetic Operations", """
a = 10
b = 3
c = a + b
d = a - b
e = a * b
f = a / b
g = a % b
""")

func _test_code(test_name: String, code: String):
	print("\n--- Test: %s ---" % test_name)
	print("Code:\n%s" % code)
	
	mock_player.reset_position()
	
	# Tokenize
	var lexer = Lexer.new()
	var tokens = lexer.tokenize(code)
	
	# Parse
	var parser = Parser.new()
	var ast = parser.parse(tokens)
	
	# Execute
	print("Executing...")
	interpreter.execute(ast, mock_player)
	
	# Wait for completion
	await interpreter.execution_complete
	
	print("Player movements: %d" % mock_player.position_log.size())
	print("Final position: %s" % mock_player.position)

func _on_test_complete():
	print("✓ Execution complete")

func _on_test_error(error_msg: String):
	print("✗ Execution error: %s" % error_msg)
