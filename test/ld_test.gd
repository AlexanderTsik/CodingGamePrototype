extends RefCounted
## Minimal zero-dependency test base for LediBug.
##
## Subclass with `extends "res://test/ld_test.gd"`, implement `func run() -> void:`
## (start it with `await tree.process_frame` so it is always a coroutine the runner
## can await), and call the assert_* helpers. The runner aggregates pass/fail counts.

var tree: SceneTree          # injected by the runner; for tests that add_child
var passed: int = 0
var failed: int = 0
var failures: Array = []
var _section: String = ""

func section(name: String) -> void:
	_section = name

func ok(cond: bool, msg: String) -> void:
	if cond:
		passed += 1
	else:
		failed += 1
		failures.append("[%s] %s" % [_section, msg])

func assert_eq(actual, expected, msg: String = "") -> void:
	ok(actual == expected, "%s (expected %s, got %s)" % [msg, str(expected), str(actual)])

func assert_ne(actual, unexpected, msg: String = "") -> void:
	ok(actual != unexpected, "%s (did not expect %s)" % [msg, str(unexpected)])

func assert_true(cond, msg: String = "") -> void:
	ok(cond == true, msg)

func assert_false(cond, msg: String = "") -> void:
	ok(cond == false, msg)

func assert_null(v, msg: String = "") -> void:
	ok(v == null, msg)

func assert_not_null(v, msg: String = "") -> void:
	ok(v != null, msg)
