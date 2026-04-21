## Animated main-menu background.
## Draws a forest-to-navy gradient with circuit traces, organic vine/leaf veins,
## pulsing firefly nodes (green + amber ladybug warmth), and a central glow.
extends Control

var _t := 0.0

const GRID_STEP    : int = 58
const NODE_COUNT   : int = 38
const TRACE_COUNT  : int = 11
const VINE_COUNT   : int = 5

var _nodes  : Array = []
var _traces : Array = []
var _vines  : Array = []
var _ready_flag := false

func _ready() -> void:
	_seed_elements()
	_ready_flag = true

func _seed_elements() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 1337

	# Pulsing firefly / circuit nodes  (positions stored as 0-1 fractions)
	for _i in NODE_COUNT:
		_nodes.append({
			"x":     rng.randf(),
			"y":     rng.randf(),
			"phase": rng.randf_range(0.0, TAU),
			"speed": rng.randf_range(0.5, 1.9),
			"r":     rng.randf_range(1.5, 3.8),
			"amber": rng.randf() > 0.62   # ~38 % amber = ladybug warmth
		})

	# Circuit traces — L-shaped PCB paths with a moving data packet
	for _i in TRACE_COUNT:
		var x1 := rng.randf_range(0.02, 0.82)
		var y1 := rng.randf_range(0.06, 0.94)
		var dx  := rng.randf_range(0.07, 0.30)
		var dy  := rng.randf_range(-0.20, 0.20)
		_traces.append({
			"pts":   [Vector2(x1, y1), Vector2(x1 + dx, y1), Vector2(x1 + dx, y1 + dy)],
			"t":     rng.randf(),
			"speed": rng.randf_range(0.04, 0.14),
			"green": rng.randf() > 0.32   # most green, some blue-teal (tech)
		})

	# Organic vine / leaf-vein paths
	for _i in VINE_COUNT:
		var sx := rng.randf_range(-0.04, 0.96)
		var sy := rng.randf_range(0.08,  0.92)
		var pts : Array = [Vector2(sx, sy)]
		var cx  := sx
		var cy  := sy
		for _j in rng.randi_range(4, 8):
			cx += rng.randf_range(0.05, 0.18)
			cy += rng.randf_range(-0.07, 0.07)
			pts.append(Vector2(cx, cy))
		_vines.append({"pts": pts, "alpha": rng.randf_range(0.05, 0.12)})

# ─── Update ───────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_t += delta
	for trace in _traces:
		trace["t"] = fmod(trace["t"] + trace["speed"] * delta, 1.0)
	queue_redraw()

# ─── Draw ─────────────────────────────────────────────────────────────────────

func _draw() -> void:
	if not _ready_flag:
		return
	var W := size.x
	var H := size.y
	if W <= 0.0 or H <= 0.0:
		return

	_draw_gradient(W, H)
	_draw_center_glow(W, H)
	_draw_grid(W, H)
	_draw_vines(W, H)
	_draw_traces(W, H)
	_draw_nodes(W, H)

# ── Gradient background ───────────────────────────────────────────────────────

func _draw_gradient(W: float, H: float) -> void:
	const BANDS := 28
	for i in BANDS:
		var t0 := float(i)     / BANDS
		var t1 := float(i + 1) / BANDS
		var c  := _bg_color((t0 + t1) * 0.5)
		draw_rect(Rect2(0.0, t0 * H, W, (t1 - t0) * H + 1.5), c, true)

func _bg_color(t: float) -> Color:
	# Top: very dark forest green
	# Mid: dark teal (where nature meets tech)
	# Bottom: deep navy (pure tech)
	var top    := Color(0.020, 0.055, 0.028, 1.0)
	var mid    := Color(0.025, 0.050, 0.062, 1.0)
	var bottom := Color(0.032, 0.037, 0.072, 1.0)
	if t < 0.45:
		return top.lerp(mid, t / 0.45)
	return mid.lerp(bottom, (t - 0.45) / 0.55)

# ── Radial glow (moonlight / ladybug light through the canopy) ────────────────

func _draw_center_glow(W: float, H: float) -> void:
	var cx := W * 0.5
	var cy := H * 0.46
	# Outer green halo — nature
	draw_circle(Vector2(cx, cy), H * 0.70, Color(0.10, 0.42, 0.20, 0.07))
	draw_circle(Vector2(cx, cy), H * 0.50, Color(0.12, 0.52, 0.25, 0.07))
	# Inner warm amber — ladybug
	draw_circle(Vector2(cx, cy), H * 0.28, Color(0.52, 0.40, 0.10, 0.07))
	draw_circle(Vector2(cx, cy), H * 0.14, Color(0.65, 0.50, 0.14, 0.06))

# ── Subtle dot grid ───────────────────────────────────────────────────────────

func _draw_grid(W: float, H: float) -> void:
	var dot_color := Color(0.22, 0.62, 0.32, 0.12)
	var x := float(GRID_STEP) * 0.5
	while x <= W:
		var y := float(GRID_STEP) * 0.5
		while y <= H:
			draw_circle(Vector2(x, y), 1.0, dot_color)
			y += GRID_STEP
		x += GRID_STEP

# ── Organic vine / leaf-vein lines ────────────────────────────────────────────

func _draw_vines(W: float, H: float) -> void:
	for vine in _vines:
		var alpha : float = vine["alpha"]
		var rel   : Array = vine["pts"]
		var pts   : Array = []
		for p: Vector2 in rel:
			pts.append(Vector2(p.x * W, p.y * H))

		var vc := Color(0.24, 0.72, 0.34, alpha)
		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], vc, 1.5)
			# Perpendicular branch — leaf vein feel
			if i % 2 == 0:
				var mid  : Vector2 = pts[i].lerp(pts[i + 1], 0.48)
				var seg  : Vector2 = pts[i + 1] - pts[i]
				var perp := Vector2(-seg.y, seg.x).normalized()
				var blen := 14.0 + 8.0 * sin(_t * 0.28 + i * 1.3)
				draw_line(mid, mid + perp * blen, Color(0.24, 0.72, 0.34, alpha * 0.55), 1.0)
			draw_circle(pts[i], 1.6, Color(0.28, 0.80, 0.38, alpha * 1.3))
		draw_circle(pts[-1], 1.6, Color(0.28, 0.80, 0.38, alpha * 1.3))

# ── Circuit traces ────────────────────────────────────────────────────────────

func _draw_traces(W: float, H: float) -> void:
	for trace in _traces:
		var is_green : bool  = trace["green"]
		var lc := Color(0.16, 0.80, 0.38, 0.18) if is_green \
				else Color(0.20, 0.60, 0.90, 0.16)

		# World-space points
		var rel : Array = trace["pts"]
		var pts : Array = []
		for p: Vector2 in rel:
			pts.append(Vector2(p.x * W, p.y * H))

		# Draw the trace lines + corner dots
		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], lc, 1.5)
		for p: Vector2 in pts:
			draw_circle(p, 2.2, lc.lightened(0.4))

		# Moving data packet along the trace
		var total := 0.0
		var segs  : Array = []
		for i in range(pts.size() - 1):
			var l : float = pts[i].distance_to(pts[i + 1])
			segs.append(l)
			total += l
		if total < 0.001:
			continue

		var target : float = trace["t"] * total
		var acc    := 0.0
		var pkt    : Vector2 = pts[0]
		for i in range(pts.size() - 1):
			if acc + segs[i] >= target:
				pkt = pts[i].lerp(pts[i + 1], (target - acc) / segs[i])
				break
			acc += segs[i]

		var pc := Color(0.42, 1.00, 0.56, 0.92) if is_green \
				else Color(0.36, 0.84, 1.00, 0.92)
		draw_circle(pkt, 3.0, pc)
		draw_circle(pkt, 7.0, Color(pc.r, pc.g, pc.b, 0.20))

# ── Pulsing firefly / circuit nodes ──────────────────────────────────────────

func _draw_nodes(W: float, H: float) -> void:
	for node in _nodes:
		var bright := 0.5 + 0.5 * sin(_t * node["speed"] + node["phase"])
		var pos    := Vector2(node["x"] * W, node["y"] * H)
		var r      : float = node["r"] * (0.65 + 0.35 * bright)

		if node["amber"]:
			# Warm ladybug amber / gold
			var c := Color(0.94, 0.72, 0.20, 0.10 + 0.40 * bright)
			draw_circle(pos, r,       c)
			draw_circle(pos, r * 2.6, Color(0.94, 0.72, 0.20, 0.035 * bright))
		else:
			# Cool leaf / circuit green
			var c := Color(0.26, 0.92, 0.46, 0.08 + 0.42 * bright)
			draw_circle(pos, r,       c)
			draw_circle(pos, r * 2.6, Color(0.26, 0.92, 0.46, 0.030 * bright))
