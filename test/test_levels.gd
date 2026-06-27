extends "res://test/ld_test.gd"

var _defs

func _solve(layout: String, code: String) -> Dictionary:
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
	await interp.execute(Parser.new().parse(Lexer.new().tokenize(code)), player)
	var res = {"on_goal": player.is_on_goal(), "pos": player.grid_position}
	interp.free()
	player.free()
	gm.free()
	return res

func run() -> void:
	await tree.process_frame
	_defs = load("res://scripts/levels/level_definitions.gd").new()

	section("all builtin levels are structurally valid")
	for n in range(1, _defs.get_level_count() + 1):
		var lv = _defs.get_level(n)
		assert_false(lv.is_empty(), "level %d exists" % n)
		var gm = GridManager.new()
		gm.load_level_from_string(lv["layout"])
		assert_true(gm.goal_positions.size() >= 1, "level %d has a goal" % n)
		assert_true(gm.is_walkable(gm.start_position), "level %d start is walkable" % n)
		if gm.goal_positions.size() >= 1:
			assert_true(gm.is_walkable(gm.goal_positions[0]), "level %d goal is walkable" % n)
			assert_ne(gm.start_position, gm.goal_positions[0], "level %d start != goal" % n)
		assert_true(GridManager.is_layout_solvable(lv["layout"]), "level %d is BFS-solvable" % n)
		gm.free()

	section("levels 6+ expose multiple variants")
	for n in range(1, _defs.get_level_count() + 1):
		var variant_count = _defs.get_level_variant_count(n)
		if n <= 5:
			assert_eq(variant_count, 1, "level %d stays single-variant" % n)
		else:
			assert_true(variant_count > 1, "level %d has multiple variants" % n)
			var variants = _defs.get_level_variants(n)
			for i in range(variants.size()):
				assert_true(GridManager.is_layout_solvable(variants[i]), "level %d variant %d is BFS-solvable" % [n, i + 1])

	section("Level 1 solves with its documented path")
	var r1 = await _solve(_defs.get_level(1)["layout"],
		"for (i in range(7)) { move() }\nturnRight()\nfor (i in range(4)) { move() }")
	assert_true(r1["on_goal"], "level 1 reaches goal (ended at %s)" % str(r1["pos"]))

	# The right-hand-rule is the intended solution for the open maze levels.
	var rhr := "while (not goalReached()) { if (rightIsClear()) { turnRight() move() } elif (frontIsClear()) { move() } else { turnLeft() } }"

	section("Level 10 solves with the right-hand rule")
	for v in _defs.get_level_variants(10):
		var r10 = await _solve(v, rhr)
		assert_true(r10["on_goal"], "level 10 variant reaches goal (ended at %s)" % str(r10["pos"]))

	section("Level 11 solves with the right-hand rule")
	for v in _defs.get_level_variants(11):
		var r11 = await _solve(v, rhr)
		assert_true(r11["on_goal"], "level 11 variant reaches goal (ended at %s)" % str(r11["pos"]))

	_defs.free()
