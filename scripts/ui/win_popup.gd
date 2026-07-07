class_name WinPopup
extends Node
## Win / leaderboard popup, extracted from main.gd.
##
## Builds its own Panel under the game controller and shows the result +
## leaderboard when a level is completed. Reads from the controller (`_main`):
## player, code_input, current_level_source/id/dict, and calls back its
## _on_restart_button_pressed / _on_next_level_button_pressed handlers.
## AuthManager / ApiClient are autoloads.

var _main  # the game controller (main.gd); untyped for dynamic member access
var _panel: Panel
var _stats: Label
var _rank_label: Label
var _lb_container: VBoxContainer
var _sfx: AudioStreamPlayer   # celebration sound on level completion

func _init(controller: Node = null) -> void:
	_main = controller

func _ready() -> void:
	if _main:
		_build()

func _build() -> void:
	_panel = Panel.new()
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color = Color(0.11, 0.12, 0.17, 0.97)
	popup_style.border_width_left   = 2
	popup_style.border_width_top    = 2
	popup_style.border_width_right  = 2
	popup_style.border_width_bottom = 2
	popup_style.border_color = Color(0.25, 0.85, 0.45, 1.0)
	popup_style.corner_radius_top_left     = 12
	popup_style.corner_radius_top_right    = 12
	popup_style.corner_radius_bottom_right = 12
	popup_style.corner_radius_bottom_left  = 12
	popup_style.shadow_color  = Color(0, 0, 0, 0.55)
	popup_style.shadow_size   = 12
	popup_style.shadow_offset = Vector2(0, 4)
	_panel.add_theme_stylebox_override("panel", popup_style)
	_panel.visible         = false
	_panel.anchor_left     = 0.5
	_panel.anchor_top      = 0.5
	_panel.anchor_right    = 0.5
	_panel.anchor_bottom   = 0.5
	_panel.offset_left     = -240.0
	_panel.offset_top      = -240.0
	_panel.offset_right    = 240.0
	_panel.offset_bottom   = 240.0
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.grow_vertical   = Control.GROW_DIRECTION_BOTH
	_main.add_child(_panel)

	# Celebration sound, played when the popup appears on a successful finish.
	_sfx = AudioStreamPlayer.new()
	_sfx.stream = load("res://assets/audio/level_complete.wav")
	add_child(_sfx)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   20)
	margin.add_theme_constant_override("margin_right",  20)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	_panel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "🎉 Level Complete!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	vbox.add_child(title)

	_stats = Label.new()
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_stats)

	_rank_label = Label.new()
	_rank_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_rank_label.add_theme_font_size_override("font_size", 15)
	vbox.add_child(_rank_label)

	vbox.add_child(HSeparator.new())

	var lb_title = Label.new()
	lb_title.text = "Top Solutions"
	lb_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lb_title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(lb_title)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.custom_minimum_size = Vector2(0, 180)
	vbox.add_child(scroll)

	_lb_container = VBoxContainer.new()
	_lb_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_lb_container)

	var btn_row = HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vbox.add_child(btn_row)

	var menu_btn = Button.new()
	menu_btn.text = "Main Menu"
	menu_btn.custom_minimum_size = Vector2(110, 36)
	menu_btn.pressed.connect(func():
		_panel.visible = false
		_main._on_menu_button_pressed()
	)
	btn_row.add_child(menu_btn)

	var retry_btn = Button.new()
	retry_btn.text = "Play Again"
	retry_btn.custom_minimum_size = Vector2(110, 36)
	retry_btn.pressed.connect(func():
		_panel.visible = false
		# Route through the same dispatcher Restart uses so custom levels work.
		_main._on_restart_button_pressed()
	)
	btn_row.add_child(retry_btn)

	var next_btn = Button.new()
	next_btn.text = "Next Level →"
	next_btn.name = "WinNextButton"   # so we can re-label it per level source
	next_btn.custom_minimum_size = Vector2(110, 36)
	next_btn.pressed.connect(func():
		_panel.visible = false
		_main._on_next_level_button_pressed()
	)
	btn_row.add_child(next_btn)

func _get_leaderboard_key() -> String:
	# Returns the leaderboard ID for the current level, or '' if it has none.
	if _main.current_level_source == "builtin":
		return "builtin_%d" % _main.current_level_id
	if _main.current_level_source == "community":
		var uuid = str(_main.current_level_dict.get("level_id", ""))
		# Guard against the legacy 999 sentinel slipping through.
		return uuid if uuid != "" and uuid != "999" else ""
	return ""  # local — no shared leaderboard

func show_result() -> void:
	var moves    = _main.player.move_count
	var code     = _main.code_input.text
	var lines    = _count_lines(code)
	var level_id = _get_leaderboard_key()

	_stats.text      = "%d moves  ·  %d lines of code" % [moves, lines]
	_rank_label.text = ""
	_panel.visible   = true
	if _sfx and _sfx.stream:
		_sfx.play()

	# Relabel the "Next Level" button to reflect what it actually does.
	var next_btn := _panel.find_child("WinNextButton", true, false) as Button
	if next_btn:
		next_btn.text = "Next Level →" if _main.current_level_source == "builtin" else "Back to Levels →"

	# Local-only custom levels don't have a leaderboard at all.
	if level_id == "":
		_set_lb_status("This level isn't on a shared leaderboard.")
		return

	_set_lb_status("Submitting solution..." if AuthManager.is_logged_in() else "Loading leaderboard...")

	# Submit first (if logged in), then fetch so the player's entry is in the DB.
	if AuthManager.is_logged_in():
		var sub_result = await ApiClient.submit_solution(level_id, code, moves, lines)
		if sub_result.has("error"):
			_rank_label.text = "Submit failed: %s" % sub_result.get("msg", sub_result["error"])
			_rank_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
		_set_lb_status("Loading leaderboard...")
	else:
		_rank_label.text = "Log in to save your score!"
		_rank_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.4))

	var entries: Array = await ApiClient.get_leaderboard(level_id)
	_clear_lb()

	if entries.is_empty():
		_set_lb_status("No solutions yet — you're first!")
		return

	_add_lb_row("#", "Player", "Moves", "Lines", true, false)

	var my_username = AuthManager.get_username() if AuthManager.is_logged_in() else ""
	var my_rank     = -1

	for i in entries.size():
		var e     = entries[i]
		var prof  = e.get("profiles", null)
		var uname = prof.get("username", "???") if prof is Dictionary else "???"
		var is_me = my_username != "" and uname == my_username
		if is_me:
			my_rank = i + 1
		_add_lb_row(str(i + 1), uname,
				str(int(e.get("move_count", 0))),
				str(int(e.get("code_length", 0))),
				false, is_me)

	if my_rank > 0:
		_rank_label.text = "Your rank: #%d" % my_rank
		_rank_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	elif AuthManager.is_logged_in():
		_rank_label.text = "Solution submitted!"
		_rank_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5))

func _count_lines(code: String) -> int:
	"""Count non-blank lines of code (the leaderboard tiebreak metric)."""
	var n := 0
	for line in code.split("\n"):
		if line.strip_edges() != "":
			n += 1
	return n

func _set_lb_status(msg: String) -> void:
	_clear_lb()
	var lbl = Label.new()
	lbl.text = msg
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lb_container.add_child(lbl)

func _clear_lb() -> void:
	for child in _lb_container.get_children():
		child.queue_free()

func _add_lb_row(rank: String, uname: String, moves: String, code_len: String,
		is_header: bool, is_me: bool) -> void:
	var row = HBoxContainer.new()
	if is_me:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.15, 0.4, 0.15, 0.6)
		row.add_theme_stylebox_override("panel", style)

	var cols   = [rank, uname, moves, code_len]
	var widths = [28,   0,     52,    52]

	for j in cols.size():
		var lbl = Label.new()
		lbl.text = cols[j]
		lbl.custom_minimum_size = Vector2(widths[j], 0)
		if widths[j] == 0:
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if is_header:
			lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		elif is_me:
			lbl.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		row.add_child(lbl)

	_lb_container.add_child(row)
