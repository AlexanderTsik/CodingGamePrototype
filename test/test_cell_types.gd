extends "res://test/ld_test.gd"

func run() -> void:
	await tree.process_frame
	var T = CellType.Type

	section("from_char")
	assert_eq(CellType.from_char("#"), T.WALL, "# is wall")
	assert_eq(CellType.from_char("."), T.EMPTY, ". is empty")
	assert_eq(CellType.from_char("S"), T.START, "S is start")
	assert_eq(CellType.from_char("G"), T.GOAL, "G is goal")
	assert_eq(CellType.from_char("X"), T.HAZARD, "X is hazard")
	assert_eq(CellType.from_char("T"), T.TELEPORTER, "T is teleporter")
	assert_eq(CellType.from_char("?"), T.EMPTY, "unknown char defaults to empty")

	section("to_char / from_char round-trip")
	for t in [T.WALL, T.EMPTY, T.START, T.GOAL, T.HAZARD, T.WATER, T.LAVA,
			T.ICE, T.TELEPORTER, T.SWITCH, T.DOOR, T.KEY, T.COIN, T.GEM]:
		assert_eq(CellType.from_char(CellType.to_char(t)), t, "round-trip %s" % CellType.get_type_name(t))
