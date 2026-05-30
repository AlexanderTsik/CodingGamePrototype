extends SceneTree
## Zero-dependency headless test runner for LediBug.
##
## Run:  godot --headless --path <project> --script res://test/runner.gd
## Exits 0 if all tests pass, 1 otherwise (suitable for CI).

const TESTS := [
	"res://test/test_cell_types.gd",
	"res://test/test_lexer.gd",
	"res://test/test_parser.gd",
	"res://test/test_grid_manager.gd",
	"res://test/test_interpreter.gd",
	"res://test/test_levels.gd",
	"res://test/test_solutions.gd",
]

func _initialize() -> void:
	# Silence in-game diagnostics during the test run. Accessed by node path
	# because the autoload global isn't bound at this script's compile time.
	var dbg = root.get_node_or_null("Dbg")
	if dbg:
		dbg.set("enabled", false)
	await _run()

func _run() -> void:
	var total_pass := 0
	var total_fail := 0
	var all_failures: Array = []
	print("\n========== LediBug test run ==========")
	for path in TESTS:
		if not ResourceLoader.exists(path):
			continue
		var script = load(path)
		if script == null:
			print("  [LOAD FAIL] %s" % path)
			total_fail += 1
			continue
		var t = script.new()
		t.tree = self
		await t.run()
		print("  %-24s %3d passed, %3d failed" % [path.get_file(), t.passed, t.failed])
		total_pass += t.passed
		total_fail += t.failed
		for f in t.failures:
			all_failures.append("%s :: %s" % [path.get_file(), f])
	print("--------------------------------------")
	if not all_failures.is_empty():
		print("FAILURES:")
		for f in all_failures:
			print("  x " + f)
	print("TOTAL: %d passed, %d failed" % [total_pass, total_fail])
	print("======================================\n")
	quit(0 if total_fail == 0 else 1)
