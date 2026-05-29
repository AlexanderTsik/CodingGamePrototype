extends "res://test/ld_test.gd"

func run() -> void:
	await tree.process_frame

	var gm = GridManager.new()
	gm.load_level_from_string("####\n#SG#\n####")

	section("dimensions & special cells")
	assert_eq(gm.grid_width, 4, "width")
	assert_eq(gm.grid_height, 3, "height")
	assert_eq(gm.start_position, Vector2i(1, 1), "start position")
	assert_eq(gm.goal_positions.size(), 1, "one goal")
	assert_eq(gm.goal_positions[0], Vector2i(2, 1), "goal position")

	section("walkability")
	assert_true(gm.is_walkable(Vector2i(1, 1)), "start is walkable")
	assert_true(gm.is_walkable(Vector2i(2, 1)), "goal is walkable")
	assert_false(gm.is_walkable(Vector2i(0, 0)), "wall not walkable")
	assert_false(gm.is_walkable(Vector2i(-1, 1)), "out of bounds not walkable")
	assert_true(gm.is_goal(Vector2i(2, 1)), "goal detected")
	gm.free()

	section("hazards are walkable but flagged deadly")
	var gm2 = GridManager.new()
	gm2.load_level_from_string("###\n#X#\n###")
	assert_true(gm2.is_walkable(Vector2i(1, 1)), "hazard is walkable")
	assert_true(gm2.is_hazard(Vector2i(1, 1)), "hazard is flagged")
	gm2.free()

	section("teleporters pair up")
	var gm3 = GridManager.new()
	gm3.load_level_from_string("#####\n#T.T#\n#####")
	assert_eq(gm3.teleporter_pairs.size(), 1, "one teleporter pair")
	gm3.free()

	section("layout solvability (BFS Start -> Goal)")
	assert_true(GridManager.is_layout_solvable("####\n#SG#\n####"), "adjacent S/G solvable")
	assert_true(GridManager.is_layout_solvable("#####\n#S.G#\n#####"), "open corridor solvable")
	assert_false(GridManager.is_layout_solvable("#####\n#S#G#\n#####"), "wall between S and G is unsolvable")
	assert_false(GridManager.is_layout_solvable("####\n#S.#\n####"), "no goal -> not solvable")
	assert_false(GridManager.is_layout_solvable("######\n#S#.G#\n######"), "goal walled off -> unsolvable")

	section("grid<->world coordinate round-trip")
	var gm4 = GridManager.new()
	gm4.load_level_from_string("###\n#S#\n###")
	gm4.tile_size = 64
	assert_eq(gm4.world_to_grid(gm4.grid_to_world(Vector2i(1, 1))), Vector2i(1, 1), "round-trip")
	gm4.free()
