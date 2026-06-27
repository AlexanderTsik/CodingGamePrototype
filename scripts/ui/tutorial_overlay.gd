class_name TutorialOverlay
extends Control
## Interactive guided tutorial overlay.
##
## First asks the player "Do you want a tutorial?". If they accept, it walks
## through the UI one step at a time — dimming the screen, spotlighting the
## relevant control, drawing an arrow toward it, and showing a small card with
## a description plus a "Next" button. Steps advance one by one until finished.
##
## Usage (from the game controller):
##     var overlay := TutorialOverlay.new(self)
##     add_child(overlay)
##     overlay.begin(steps)            # steps: Array[Dictionary]
##
## Each step is a Dictionary, targeting EITHER a Control node or a Rect2:
##     { "node": Control, "title": String, "text": String }
##     { "rect_getter": Callable, "title": String, "text": String }
## `rect_getter` is called every frame and returns a Rect2 (global/screen
## coords) to spotlight — used to point at a single grid cell.
##
## For a one-off explanation (no Yes/No prompt), call:
##     overlay.explain(title, text, rect_getter, accent_color)

var _main                       # game controller (main.gd); untyped for dynamic access
var _steps: Array = []
var _index: int = 0
var _active: bool = false       # true only while the guided tour is running

# Spotlight / arrow state (in this overlay's local coordinates)
var _target_rect: Rect2 = Rect2()
var _card_side: String = "below"   # where the card sits relative to the target
var _pulse: float = 0.0

# Accent colors (recolored per call so hazards can use red, lava orange, etc.)
var _accent_hilite: Color = HILITE_COLOR
var _accent_arrow: Color = ARROW_COLOR

# Built UI
var _confirm_dialog: ConfirmationDialog
var _card: Panel
var _card_style: StyleBoxFlat
var _title_label: Label
var _text_label: Label
var _progress_label: Label
var _next_button: Button
var _skip_button: Button

const CARD_SIZE := Vector2(360, 200)
const DIM_COLOR := Color(0, 0, 0, 0.62)
const HILITE_COLOR := Color(0.30, 0.85, 0.45, 1.0)
const ARROW_COLOR := Color(0.40, 0.95, 0.55, 1.0)

func _init(controller: Node = null) -> void:
	_main = controller

func _ready() -> void:
	# Cover the whole screen and sit on top of the game UI. The overlay stays
	# visible (so the child dialog can render) but draws nothing and ignores the
	# mouse until the tour is actually running (_active).
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)
	_build_confirm_dialog()
	_build_card()

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

func begin(steps: Array) -> void:
	"""Show the Yes/No prompt; on Yes, run the guided tour over `steps`."""
	_steps = steps
	_confirm_dialog.popup_centered()

func is_active() -> bool:
	"""True while a tour or explanation is on screen."""
	return _active

func explain(title: String, text: String, rect_getter: Callable, accent: Color = HILITE_COLOR) -> void:
	"""Show a single spotlight explanation pointing at `rect_getter`'s Rect2.
	No Yes/No prompt — runs immediately. Ignored if already active."""
	if _active:
		return
	_steps = [{ "title": title, "text": text, "rect_getter": rect_getter }]
	_set_accent(accent)
	_index = 0
	_active = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	move_to_front()
	_card.visible = true
	set_process(true)
	_show_step()

func _set_accent(c: Color) -> void:
	_accent_hilite = c
	_accent_arrow = c.lightened(0.15)
	if _card_style:
		_card_style.border_color = c
	if _title_label:
		_title_label.add_theme_color_override("font_color", c)

# ─────────────────────────────────────────────────────────────────────────────
# Build UI
# ─────────────────────────────────────────────────────────────────────────────

func _build_confirm_dialog() -> void:
	_confirm_dialog = ConfirmationDialog.new()
	_confirm_dialog.exclusive = false
	_confirm_dialog.title = "Tutorial"
	_confirm_dialog.dialog_text = \
		"Welcome to LediBug!\n\nWould you like a quick tour of the controls?"
	_confirm_dialog.ok_button_text = "Yes, show me"
	_confirm_dialog.get_cancel_button().text = "No thanks"
	_confirm_dialog.confirmed.connect(_on_tutorial_accepted)
	add_child(_confirm_dialog)

func _build_card() -> void:
	_card = Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.11, 0.12, 0.17, 0.98)
	style.border_width_left   = 2
	style.border_width_top    = 2
	style.border_width_right   = 2
	style.border_width_bottom = 2
	style.border_color = HILITE_COLOR
	style.corner_radius_top_left     = 10
	style.corner_radius_top_right    = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left  = 10
	style.shadow_color  = Color(0, 0, 0, 0.55)
	style.shadow_size   = 14
	style.shadow_offset = Vector2(0, 5)
	_card_style = style
	_card.add_theme_stylebox_override("panel", style)
	_card.size = CARD_SIZE
	_card.visible = false
	_card.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_card)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   16)
	margin.add_theme_constant_override("margin_right",  16)
	margin.add_theme_constant_override("margin_top",    14)
	margin.add_theme_constant_override("margin_bottom", 14)
	_card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 18)
	_title_label.add_theme_color_override("font_color", Color(0.40, 0.95, 0.55, 1))
	vbox.add_child(_title_label)

	_text_label = Label.new()
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 14)
	_text_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.96, 1))
	_text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(_text_label)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	vbox.add_child(footer)

	_progress_label = Label.new()
	_progress_label.add_theme_font_size_override("font_size", 12)
	_progress_label.add_theme_color_override("font_color", Color(0.55, 0.62, 0.72, 1))
	_progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_progress_label)

	_skip_button = Button.new()
	_skip_button.text = "Skip"
	_skip_button.add_theme_stylebox_override("normal",  _make_btn_style(Color(0.063, 0.075, 0.118, 1), Color(0.165, 0.196, 0.306, 1)))
	_skip_button.add_theme_stylebox_override("hover",   _make_btn_style(Color(0.10, 0.11, 0.16, 1), Color(0.30, 0.34, 0.46, 1)))
	_skip_button.add_theme_stylebox_override("pressed", _make_btn_style(Color(0.10, 0.11, 0.16, 1), Color(0.30, 0.34, 0.46, 1)))
	_skip_button.pressed.connect(_finish)
	footer.add_child(_skip_button)

	_next_button = Button.new()
	_next_button.text = "Next"
	_next_button.add_theme_stylebox_override("normal",  _make_btn_style(Color(0.075, 0.455, 0.216, 1), Color(0, 0, 0, 0)))
	_next_button.add_theme_stylebox_override("hover",   _make_btn_style(Color(0.098, 0.576, 0.271, 1), Color(0, 0, 0, 0)))
	_next_button.add_theme_stylebox_override("pressed", _make_btn_style(Color(0.098, 0.576, 0.271, 1), Color(0, 0, 0, 0)))
	_next_button.pressed.connect(_on_next_pressed)
	footer.add_child(_next_button)

func _make_btn_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	if border.a > 0.0:
		s.border_width_left = 1
		s.border_width_top = 1
		s.border_width_right = 1
		s.border_width_bottom = 1
		s.border_color = border
	s.corner_radius_top_left     = 6
	s.corner_radius_top_right    = 6
	s.corner_radius_bottom_right = 6
	s.corner_radius_bottom_left  = 6
	s.content_margin_left   = 14
	s.content_margin_right  = 14
	s.content_margin_top    = 6
	s.content_margin_bottom = 6
	return s

# ─────────────────────────────────────────────────────────────────────────────
# Tour flow
# ─────────────────────────────────────────────────────────────────────────────

func _on_tutorial_accepted() -> void:
	if _steps.is_empty():
		return
	_set_accent(HILITE_COLOR)   # the guided tour always uses the default green
	_index = 0
	_active = true
	mouse_filter = Control.MOUSE_FILTER_STOP   # block clicks to the game during the tour
	move_to_front()
	_card.visible = true
	set_process(true)
	_show_step()

func _on_next_pressed() -> void:
	_index += 1
	if _index >= _steps.size():
		_finish()
	else:
		_show_step()

func _show_step() -> void:
	var step: Dictionary = _steps[_index]
	var node = step.get("node", null)
	var rect_getter = step.get("rect_getter", null)

	_title_label.text = step.get("title", "")
	_text_label.text  = step.get("text", "")
	if _steps.size() <= 1:
		_progress_label.text = ""
	else:
		_progress_label.text = "Step %d / %d" % [_index + 1, _steps.size()]
	_next_button.text = "Got it!" if _index == _steps.size() - 1 else "Next"
	_skip_button.visible = _steps.size() > 1

	# Compute the spotlight rect from a rect_getter or the target node.
	if rect_getter is Callable and (rect_getter as Callable).is_valid():
		_target_rect = ((rect_getter as Callable).call() as Rect2).grow(8.0)
	elif node and is_instance_valid(node) and node is Control:
		_target_rect = (node as Control).get_global_rect().grow(8.0)
	else:
		_target_rect = Rect2()

	_position_card()
	queue_redraw()

func _position_card() -> void:
	var vp := get_viewport_rect().size
	var t := _target_rect
	var pos: Vector2

	if t.size == Vector2.ZERO:
		# No target — center the card.
		pos = (vp - CARD_SIZE) * 0.5
		_card_side = "center"
	else:
		var space_below := vp.y - t.end.y
		var space_above := t.position.y
		var space_right := vp.x - t.end.x
		if space_below >= CARD_SIZE.y + 24:
			pos = Vector2(t.position.x, t.end.y + 18)
			_card_side = "below"
		elif space_above >= CARD_SIZE.y + 24:
			pos = Vector2(t.position.x, t.position.y - CARD_SIZE.y - 18)
			_card_side = "above"
		elif space_right >= CARD_SIZE.x + 24:
			pos = Vector2(t.end.x + 18, t.position.y)
			_card_side = "right"
		else:
			pos = Vector2(t.position.x - CARD_SIZE.x - 18, t.position.y)
			_card_side = "left"

	pos.x = clampf(pos.x, 12.0, vp.x - CARD_SIZE.x - 12.0)
	pos.y = clampf(pos.y, 12.0, vp.y - CARD_SIZE.y - 12.0)
	_card.position = pos

func _finish() -> void:
	_active = false
	set_process(false)
	_card.visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()

# ─────────────────────────────────────────────────────────────────────────────
# Drawing — spotlight dim, highlight border, arrow
# ─────────────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_pulse += delta * 3.0
	# Re-track the target in case the layout shifted, then redraw the pulse.
	if _index < _steps.size():
		var step: Dictionary = _steps[_index]
		var rect_getter = step.get("rect_getter", null)
		var node = step.get("node", null)
		if rect_getter is Callable and (rect_getter as Callable).is_valid():
			_target_rect = ((rect_getter as Callable).call() as Rect2).grow(8.0)
			_position_card()
		elif node and is_instance_valid(node) and node is Control:
			_target_rect = (node as Control).get_global_rect().grow(8.0)
			_position_card()
	queue_redraw()

func _draw() -> void:
	if not _active:
		return
	var vp := get_viewport_rect().size

	if _target_rect.size == Vector2.ZERO:
		draw_rect(Rect2(Vector2.ZERO, vp), DIM_COLOR)
		return

	var t := _target_rect
	# Dim everything around the spotlight (four surrounding rectangles).
	draw_rect(Rect2(0, 0, vp.x, t.position.y), DIM_COLOR)
	draw_rect(Rect2(0, t.end.y, vp.x, vp.y - t.end.y), DIM_COLOR)
	draw_rect(Rect2(0, t.position.y, t.position.x, t.size.y), DIM_COLOR)
	draw_rect(Rect2(t.end.x, t.position.y, vp.x - t.end.x, t.size.y), DIM_COLOR)

	# Pulsing highlight border around the target.
	var pulse := 0.5 + 0.5 * sin(_pulse)
	var border_col := _accent_hilite
	border_col.a = 0.55 + 0.45 * pulse
	draw_rect(t, border_col, false, 3.0)

	# Arrow from the card toward the target.
	_draw_arrow()

func _draw_arrow() -> void:
	if _card_side == "center":
		return

	var card_rect := Rect2(_card.position, CARD_SIZE)
	var t := _target_rect
	var start: Vector2
	var end: Vector2

	# Anchor the arrow to the MIDDLE of the edges facing each other, so the
	# arrowhead lands on the target's edge midpoint (e.g. bottom-middle) rather
	# than a corner.
	match _card_side:
		"below":
			start = Vector2(card_rect.get_center().x, card_rect.position.y)  # card top-middle
			end   = Vector2(t.get_center().x, t.end.y)                       # target bottom-middle
		"above":
			start = Vector2(card_rect.get_center().x, card_rect.end.y)       # card bottom-middle
			end   = Vector2(t.get_center().x, t.position.y)                  # target top-middle
		"right":
			start = Vector2(card_rect.position.x, card_rect.get_center().y)  # card left-middle
			end   = Vector2(t.end.x, t.get_center().y)                       # target right-middle
		_:  # "left"
			start = Vector2(card_rect.end.x, card_rect.get_center().y)       # card right-middle
			end   = Vector2(t.position.x, t.get_center().y)                  # target left-middle

	if start.distance_to(end) < 6.0:
		return

	draw_line(start, end, _accent_arrow, 3.0, true)

	# Arrowhead at the target end.
	var dir := (end - start).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var head := 14.0
	var p1 := end - dir * head + perp * (head * 0.55)
	var p2 := end - dir * head - perp * (head * 0.55)
	draw_colored_polygon(PackedVector2Array([end, p1, p2]), ARROW_COLOR)
