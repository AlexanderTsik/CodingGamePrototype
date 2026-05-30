extends "res://test/ld_test.gd"
## Automated regression test: verifies every level's solution_code actually
## solves the level (and all its variants) by running it through the interpreter.

var _defs

func _solve_variant(layout: String, code: String) -> Dictionary:
	"""Run `code` on a single grid layout, return whether player ended on goal."""
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
	var result = {"on_goal": player.is_on_goal(), "pos": player.grid_position}
	interp.free()
	player.free()
	gm.free()
	return result

func _solve_all_variants(level_id: int, code: String) -> bool:
	"""Run `code` on every variant of a level, re-running from scratch each time.
	Returns true only if the player ends on the goal for ALL variants."""
	var variants = _defs.get_level_variants(level_id)
	for i in range(variants.size()):
		var r = await _solve_variant(variants[i], code)
		if not r["on_goal"]:
			ok(false, "level %d variant %d: ended at %s, not on goal" % [level_id, i + 1, str(r["pos"])])
			return false
	return true

func run() -> void:
	await tree.process_frame
	_defs = load("res://scripts/levels/level_definitions.gd").new()

	section("every level has a solution_code field")
	for n in range(1, _defs.get_level_count() + 1):
		var sol = _defs.get_solution_code(n)
		assert_true(sol != "", "level %d has solution_code" % n)

	section("solution solves all variants for every level")
	for n in range(1, _defs.get_level_count() + 1):
		var sol = _defs.get_solution_code(n)
		var ok_all = await _solve_all_variants(n, sol)
		if ok_all:
			ok(true, "level %d solution solves all variants" % n)

	_defs.free()
