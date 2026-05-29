extends "res://test/ld_test.gd"

# Open 7x5 room, start at (1,1). Open cells x=1..5 on rows 1..3.
const ROOM := "#######\n#S....#\n#.....#\n#.....#\n#######"

func _setup(layout: String) -> Dictionary:
	var gm = GridManager.new()
	gm.load_level_from_string(layout)
	var player = load("res://scripts/core/player.gd").new()
	player.grid_manager = gm
	tree.root.add_child(gm)
	tree.root.add_child(player)
	player.reset_position()
	var interp = Interpreter.new()
	interp.instant = true
	tree.root.add_child(interp)
	return {"gm": gm, "player": player, "interp": interp}

func _teardown(c: Dictionary) -> void:
	c.interp.free()
	c.player.free()
	c.gm.free()

func _exec(c: Dictionary, code: String) -> void:
	await c.interp.execute(Parser.new().parse(Lexer.new().tokenize(code)), c.player)

func run() -> void:
	await tree.process_frame
	var c

	section("sequential commands")
	c = _setup(ROOM)
	await _exec(c, "turnRight()\nmove()\nmove()")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "two steps east")
	_teardown(c)

	section("for loop iterates n times")
	c = _setup(ROOM)
	await _exec(c, "turnRight()\nfor (i in range(3)) { move() }")
	assert_eq(c.player.grid_position, Vector2i(4, 1), "three steps east")
	_teardown(c)

	section("variables drive loop count")
	c = _setup(ROOM)
	await _exec(c, "n = 2\nturnRight()\nfor (i in range(n)) { move() }")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "n=2 steps east")
	_teardown(c)

	section("arithmetic inside range")
	c = _setup(ROOM)
	await _exec(c, "turnRight()\nfor (i in range(1 + 2)) { move() }")
	assert_eq(c.player.grid_position, Vector2i(4, 1), "1+2 steps east")
	_teardown(c)

	section("while + frontIsClear walks to the wall")
	c = _setup(ROOM)
	await _exec(c, "turnRight()\nwhile (frontIsClear()) { move() }")
	assert_eq(c.player.grid_position, Vector2i(5, 1), "stops before east wall")
	_teardown(c)

	section("if/else takes the open branch")
	# Facing up at (1,1); up is a wall, so the else branch runs.
	c = _setup(ROOM)
	await _exec(c, "if (frontIsClear()) { move() } else { turnRight() move() }")
	assert_eq(c.player.grid_position, Vector2i(2, 1), "else branch: one step east")
	_teardown(c)

	section("function definition + call")
	c = _setup(ROOM)
	await _exec(c, "function hop() { move() move() }\nturnRight()\nhop()")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "function moved twice")
	_teardown(c)

	section("function with a parameter")
	c = _setup(ROOM)
	await _exec(c, "function walk(n) { for (i in range(n)) { move() } }\nturnRight()\nwalk(3)")
	assert_eq(c.player.grid_position, Vector2i(4, 1), "walk(3) moved three")
	_teardown(c)

	section("nested loops")
	c = _setup(ROOM)
	await _exec(c, "turnRight()\nfor (i in range(2)) { for (j in range(2)) { move() } }")
	assert_eq(c.player.grid_position, Vector2i(5, 1), "2x2 = four steps east")
	_teardown(c)

	section("boolean: not goalReached + and/or evaluate")
	c = _setup(ROOM)
	await _exec(c, "turnRight()\nwhile (not goalReached() and frontIsClear()) { move() }")
	assert_eq(c.player.grid_position, Vector2i(5, 1), "loop honored compound condition")
	_teardown(c)

	section("function return value used in range()")
	c = _setup(ROOM)
	await _exec(c, "function two() { return 2 }\nturnRight()\nfor (i in range(two())) { move() }")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "range(two()) = 2 steps east")
	_teardown(c)

	section("function call inside an if condition")
	c = _setup(ROOM)
	await _exec(c, "function yes() { return 1 }\nif (yes() > 0) { turnRight() move() }")
	assert_eq(c.player.grid_position, Vector2i(2, 1), "yes() > 0 true: one step east")
	_teardown(c)

	section("function return inside arithmetic")
	c = _setup(ROOM)
	await _exec(c, "function two() { return 2 }\nturnRight()\nfor (i in range(two() + 1)) { move() }")
	assert_eq(c.player.grid_position, Vector2i(4, 1), "range(2 + 1) = 3 steps east")
	_teardown(c)

	section("nested function calls")
	c = _setup(ROOM)
	await _exec(c, "function one() { return 1 }\nfunction inc(n) { return n + 1 }\nturnRight()\nfor (i in range(inc(one()))) { move() }")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "inc(one()) = 2 steps east")
	_teardown(c)

	section("return exits the function early")
	c = _setup(ROOM)
	await _exec(c, "function f() { return 2\nmove() move() move() }\nturnRight()\nfor (i in range(f())) { move() }")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "early return: f()=2, inner moves skipped")
	_teardown(c)

	section("non-instant path animates and still lands correctly")
	# Exercises the real tween + scaled-delay path (instant mode skips it).
	c = _setup(ROOM)
	c.interp.instant = false
	c.interp.set_execution_speed(5.0)
	await _exec(c, "turnRight()\nmove()\nmove()")
	assert_eq(c.player.grid_position, Vector2i(3, 1), "animated moves land correctly")
	_teardown(c)

	section("boolean literal in a condition")
	c = _setup(ROOM)
	await _exec(c, "if (true) { turnRight() move() }")
	assert_eq(c.player.grid_position, Vector2i(2, 1), "if(true) ran")
	_teardown(c)

	section("if(false) is skipped")
	c = _setup(ROOM)
	await _exec(c, "if (false) { move() move() move() }")
	assert_eq(c.player.grid_position, Vector2i(1, 1), "if(false) did nothing")
	_teardown(c)

	section("boolean variable + not")
	c = _setup(ROOM)
	await _exec(c, "go = true\nif (not go) { } else { turnRight() move() }")
	assert_eq(c.player.grid_position, Vector2i(2, 1), "not true -> else branch")
	_teardown(c)

	section("float modulo uses fmod instead of crashing")
	c = _setup(ROOM)
	var ferr = [""]
	c.interp.execution_error.connect(func(m): ferr[0] = m)
	await _exec(c, "x = 5.5 % 2.0\nturnRight()\nmove()")
	assert_eq(ferr[0], "", "no error on float modulo")
	assert_eq(c.player.grid_position, Vector2i(2, 1), "execution continued past float modulo")
	_teardown(c)

	section("division by zero is reported")
	c = _setup(ROOM)
	var errs = [""]
	c.interp.execution_error.connect(func(m): errs[0] = m)
	await _exec(c, "x = 5 / 0")
	assert_ne(errs[0], "", "execution_error emitted")
	_teardown(c)

	section("infinite loop is stopped by the iteration guard")
	c = _setup(ROOM)
	var errs2 = [""]
	c.interp.execution_error.connect(func(m): errs2[0] = m)
	await _exec(c, "x = 0\nwhile (x == 0) { x = 0 }")
	assert_ne(errs2[0], "", "iteration guard fired")
	_teardown(c)
