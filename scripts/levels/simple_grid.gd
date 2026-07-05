extends Control

@export var background_color: Color = Color(0.07, 0.08, 0.11, 1.0)

var grid_manager: GridManager

const CELL_PAD       := 2
const SPRITE_NATURAL := 320.0  # LediBugSprite.png at scale 1.0 = 320 px

signal cell_size_changed(new_size: int)

# Pixel offset that centres the grid inside the panel. The player layer (the
# child "Level" Node2D) is moved by this same amount so sprites stay aligned
# with the drawn cells; spotlight math in main.gd also reads this.
var grid_offset: Vector2 = Vector2.ZERO

func _ready():
	queue_redraw()

func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		queue_redraw()

# ── Dynamic cell size ──────────────────────────────────────────────────────────
func _calc_cell_size() -> int:
	if not grid_manager or grid_manager.grid_width <= 0 or grid_manager.grid_height <= 0:
		return 48
	if size.x <= 0 or size.y <= 0:
		return 48
	return max(int(min(size.x / grid_manager.grid_width,
					   size.y / grid_manager.grid_height)), 4)

# ── Drawing ───────────────────────────────────────────────────────────────────
func _draw():
	var cols := grid_manager.grid_width  if (grid_manager and grid_manager.grid_width  > 0) else 10
	var rows := grid_manager.grid_height if (grid_manager and grid_manager.grid_height > 0) else 10

	var cs := _calc_cell_size()

	# Propagate new tile size so player + grid_manager stay in sync
	if grid_manager and grid_manager.tile_size != cs:
		grid_manager.tile_size = cs
		cell_size_changed.emit(cs)

	# Full-panel background (drawn before the centring transform so it fills
	# the whole panel, even the margins around the centred grid).
	draw_rect(Rect2(Vector2.ZERO, size), background_color, true)

	# Centre the grid inside the panel and shift the player layer to match.
	grid_offset = Vector2(
		floor(maxf((size.x - cols * cs) * 0.5, 0.0)),
		floor(maxf((size.y - rows * cs) * 0.5, 0.0)))
	var level := get_node_or_null("Level")
	if level is Node2D:
		(level as Node2D).position = grid_offset

	draw_set_transform(grid_offset, 0.0, Vector2.ONE)

	if grid_manager and grid_manager.grid.size() > 0:
		_draw_cells(cols, rows, cs)

	_draw_grid_lines(cols, rows, cs)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_cells(cols: int, rows: int, cs: int):
	for y in range(rows):
		for x in range(cols):
			var ct: CellType.Type = grid_manager.grid[y][x]
			var color := CellType.get_color(ct)
			var ox := float(x * cs + CELL_PAD)
			var oy := float(y * cs + CELL_PAD)
			var sw := float(cs - CELL_PAD * 2)
			var sh := float(cs - CELL_PAD * 2)

			draw_rect(Rect2(Vector2(ox, oy), Vector2(sw, sh)), color, true)

			if ct == CellType.Type.WALL:
				_bevel(ox, oy, sw, sh, color)
			else:
				# Top highlight / bottom shadow
				draw_rect(Rect2(Vector2(ox, oy),          Vector2(sw, 2)), color.lightened(0.45), true)
				draw_rect(Rect2(Vector2(ox, oy + sh - 2), Vector2(sw, 2)), color.darkened(0.45),  true)

				if ct != CellType.Type.START and ct != CellType.Type.EMPTY:
					_decorate(ct, ox, oy, sw, sh, cs)

func _bevel(ox: float, oy: float, sw: float, sh: float, color: Color):
	var lw := maxf(sw * 0.06, 1.5)
	draw_line(Vector2(ox,      oy),      Vector2(ox + sw, oy),      color.lightened(0.45), lw)
	draw_line(Vector2(ox,      oy),      Vector2(ox,      oy + sh), color.lightened(0.28), lw * 0.85)
	draw_line(Vector2(ox,      oy + sh), Vector2(ox + sw, oy + sh), color.darkened(0.55),  lw * 0.85)
	draw_line(Vector2(ox + sw, oy),      Vector2(ox + sw, oy + sh), color.darkened(0.40),  lw * 0.85)

func _decorate(ct: CellType.Type, ox: float, oy: float, sw: float, sh: float, cs: int):
	var cx  := ox + sw * 0.5
	var cy  := oy + sh * 0.5
	var r   := sw * 0.22
	var lw  := maxf(cs * 0.055, 1.2)

	match ct:
		CellType.Type.GOAL:
			draw_circle(Vector2(cx, cy), r * 1.1, Color(1, 1, 1, 0.15))
			draw_circle(Vector2(cx, cy), r * 0.6, Color(1, 1, 1, 0.45))

		CellType.Type.LAVA:
			var m := sw * 0.18
			draw_line(Vector2(ox + m, oy + m), Vector2(ox + sw - m, oy + sh - m), Color(1, 0.2, 0.1, 0.75), lw * 1.3)
			draw_line(Vector2(ox + sw - m, oy + m), Vector2(ox + m, oy + sh - m), Color(1, 0.2, 0.1, 0.75), lw * 1.3)

		CellType.Type.TELEPORTER:
			draw_arc(Vector2(cx, cy), r,       0.0, TAU, 24, Color(1, 1, 1, 0.38), lw)
			draw_arc(Vector2(cx, cy), r * 0.5, 0.0, TAU, 16, Color(1, 1, 1, 0.62), lw)
			draw_circle(Vector2(cx, cy), r * 0.2, Color(1, 1, 1, 0.72))

		CellType.Type.KEY:
			draw_arc(Vector2(cx - r * 0.15, cy - r * 0.25), r * 0.38, 0.0, TAU, 16, Color(1, 1, 1, 0.72), lw)
			draw_line(Vector2(cx, cy - r * 0.05), Vector2(cx + r * 0.82, cy - r * 0.05), Color(1, 1, 1, 0.72), lw)

		CellType.Type.DOOR:
			# Door panel outline with a round keyhole.
			var dm := sw * 0.22
			draw_rect(Rect2(ox + dm, oy + dm, sw - dm * 2.0, sh - dm * 1.4), Color(1, 1, 1, 0.30), false, lw)
			draw_circle(Vector2(cx, cy - r * 0.1), r * 0.22, Color(1, 1, 1, 0.78))
			draw_line(Vector2(cx, cy - r * 0.1), Vector2(cx, cy + r * 0.45), Color(1, 1, 1, 0.78), lw)

func _draw_grid_lines(cols: int, rows: int, cs: int):
	var lc := Color(0.18, 0.20, 0.26, 0.65)
	for i in range(cols + 1):
		draw_line(Vector2(i * cs, 0), Vector2(i * cs, rows * cs), lc, 1.0)
	for i in range(rows + 1):
		draw_line(Vector2(0, i * cs), Vector2(cols * cs, i * cs), lc, 1.0)

func refresh():
	# Immediately recalculate tile_size so anything that depends on world
	# coordinates (player.reset_position, move animations) uses the correct
	# value — don't wait for the next _draw() frame.
	if grid_manager:
		var cs = _calc_cell_size()
		if grid_manager.tile_size != cs:
			grid_manager.tile_size = cs
			cell_size_changed.emit(cs)
	queue_redraw()
