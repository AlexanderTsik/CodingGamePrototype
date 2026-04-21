extends Control

@export var background_color: Color = Color(0.07, 0.08, 0.11, 1.0)

var grid_manager: GridManager

const CELL_PAD       := 2
const SPRITE_NATURAL := 320.0  # LediBugSprite.png at scale 1.0 = 320 px

signal cell_size_changed(new_size: int)

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

	draw_rect(Rect2(Vector2.ZERO, size), background_color, true)

	if grid_manager and grid_manager.grid.size() > 0:
		_draw_cells(cols, rows, cs)

	_draw_grid_lines(cols, rows, cs)

func _draw_cells(cols: int, rows: int, cs: int):
	for y in range(rows):
		for x in range(cols):
			var ct: CellType.Type = grid_manager.grid[y][x]
			if ct == CellType.Type.EMPTY:
				continue

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

				if ct != CellType.Type.START:
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

		CellType.Type.HAZARD, CellType.Type.LAVA, CellType.Type.TRAP:
			var m := sw * 0.18
			draw_line(Vector2(ox + m, oy + m), Vector2(ox + sw - m, oy + sh - m), Color(1, 0.2, 0.1, 0.75), lw * 1.3)
			draw_line(Vector2(ox + sw - m, oy + m), Vector2(ox + m, oy + sh - m), Color(1, 0.2, 0.1, 0.75), lw * 1.3)

		CellType.Type.TELEPORTER:
			draw_arc(Vector2(cx, cy), r,       0.0, TAU, 24, Color(1, 1, 1, 0.38), lw)
			draw_arc(Vector2(cx, cy), r * 0.5, 0.0, TAU, 16, Color(1, 1, 1, 0.62), lw)
			draw_circle(Vector2(cx, cy), r * 0.2, Color(1, 1, 1, 0.72))

		CellType.Type.COIN:
			draw_circle(Vector2(cx, cy), r * 0.9, Color(1, 0.9, 0.1, 0.30))
			draw_arc(Vector2(cx, cy), r * 0.7, 0.0, TAU, 20, Color(1, 0.9, 0.1, 0.82), lw)

		CellType.Type.GEM:
			var pts := [Vector2(cx, cy - r), Vector2(cx + r, cy),
						Vector2(cx, cy + r), Vector2(cx - r, cy), Vector2(cx, cy - r)]
			for i in range(4):
				draw_line(pts[i], pts[i + 1], Color(1, 1, 1, 0.62), lw)

		CellType.Type.KEY:
			draw_arc(Vector2(cx - r * 0.15, cy - r * 0.25), r * 0.38, 0.0, TAU, 16, Color(1, 1, 1, 0.72), lw)
			draw_line(Vector2(cx, cy - r * 0.05), Vector2(cx + r * 0.82, cy - r * 0.05), Color(1, 1, 1, 0.72), lw)

		CellType.Type.ICE:
			for a in [0.0, PI / 3.0, PI * 2.0 / 3.0]:
				var dx := cos(a) * r;  var dy := sin(a) * r
				draw_line(Vector2(cx - dx, cy - dy), Vector2(cx + dx, cy + dy), Color(1, 1, 1, 0.50), lw)

		CellType.Type.WATER:
			for i in range(2):
				var yw := oy + sh * (0.35 + i * 0.28)
				draw_arc(Vector2(cx - r * 0.3, yw),  r * 0.38, PI, 0.0, 8, Color(1, 1, 1, 0.38), lw)
				draw_arc(Vector2(cx + r * 0.38, yw), r * 0.38, PI, 0.0, 8, Color(1, 1, 1, 0.38), lw)

		CellType.Type.SWITCH:
			draw_arc(Vector2(cx, cy), r * 0.82, 0.0, TAU, 20, Color(1, 1, 1, 0.35), lw)
			draw_circle(Vector2(cx, cy), r * 0.42, Color(1, 1, 1, 0.65))

		CellType.Type.CHECKPOINT:
			draw_line(Vector2(cx - r * 0.5, cy),          Vector2(cx - r * 0.1, cy + r * 0.5), Color(1, 1, 1, 0.80), lw)
			draw_line(Vector2(cx - r * 0.1, cy + r * 0.5), Vector2(cx + r * 0.6, cy - r * 0.4), Color(1, 1, 1, 0.80), lw)

func _draw_grid_lines(cols: int, rows: int, cs: int):
	var lc := Color(0.18, 0.20, 0.26, 0.65)
	for i in range(cols + 1):
		draw_line(Vector2(i * cs, 0), Vector2(i * cs, rows * cs), lc, 1.0)
	for i in range(rows + 1):
		draw_line(Vector2(0, i * cs), Vector2(cols * cs, i * cs), lc, 1.0)

func refresh():
	queue_redraw()
