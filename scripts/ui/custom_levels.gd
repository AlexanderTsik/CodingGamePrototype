## Custom levels screen — nature-tech theme, dynamically built level cards.
extends Control

var pending_delete_path: String = ""

# Shared styles built once
var _s_card    : StyleBoxFlat
var _s_play    : StyleBoxFlat
var _s_play_hv : StyleBoxFlat
var _s_edit    : StyleBoxFlat
var _s_edit_hv : StyleBoxFlat
var _s_del     : StyleBoxFlat
var _s_del_hv  : StyleBoxFlat

func _ready() -> void:
	_build_styles()
	$MarginContainer/ContentCard/CardInner/VBoxContainer/ButtonContainer/BackButton.pressed.connect(_on_back_pressed)
	$MarginContainer/ContentCard/CardInner/VBoxContainer/ButtonContainer/RefreshButton.pressed.connect(_on_refresh_pressed)
	$DeleteConfirmDialog.confirmed.connect(_on_delete_confirmed)
	_load_custom_levels()

# ─── Style builders ───────────────────────────────────────────────────────────

func _build_styles() -> void:
	# Level card background
	_s_card = StyleBoxFlat.new()
	_s_card.bg_color = Color(0.055, 0.063, 0.100, 0.95)
	_s_card.border_width_left   = 1
	_s_card.border_width_top    = 1
	_s_card.border_width_right  = 1
	_s_card.border_width_bottom = 1
	_s_card.border_color = Color(0.18, 0.48, 0.28, 0.65)
	_s_card.corner_radius_top_left     = 8
	_s_card.corner_radius_top_right    = 8
	_s_card.corner_radius_bottom_right = 8
	_s_card.corner_radius_bottom_left  = 8
	_s_card.shadow_color  = Color(0, 0, 0, 0.40)
	_s_card.shadow_size   = 8
	_s_card.shadow_offset = Vector2(0, 4)

	# Play — primary green
	_s_play = _make_flat(Color(0.075, 0.455, 0.216, 1), Color(0, 0, 0, 0), 0, 5)
	_s_play_hv = _make_flat(Color(0.098, 0.576, 0.271, 1), Color(0, 0, 0, 0), 0, 5)

	# Edit — neutral dark
	_s_edit    = _make_flat(Color(0.063, 0.075, 0.118, 1), Color(0.165, 0.196, 0.306, 1), 1, 5)
	_s_edit_hv = _make_flat(Color(0.071, 0.110, 0.082, 1), Color(0.22, 0.58, 0.32, 1),   1, 5)

	# Delete — danger
	_s_del    = _make_flat(Color(0.145, 0.063, 0.039, 1), Color(0.306, 0.110, 0.078, 1), 1, 5)
	_s_del_hv = _make_flat(Color(0.576, 0.129, 0.082, 1), Color(0.780, 0.176, 0.110, 1), 1, 5)

func _make_flat(bg: Color, border: Color, bw: int, cr: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	if bw > 0:
		s.border_width_left   = bw
		s.border_width_top    = bw
		s.border_width_right  = bw
		s.border_width_bottom = bw
		s.border_color = border
	s.corner_radius_top_left     = cr
	s.corner_radius_top_right    = cr
	s.corner_radius_bottom_right = cr
	s.corner_radius_bottom_left  = cr
	s.content_margin_left   = 8
	s.content_margin_right  = 8
	s.content_margin_top    = 5
	s.content_margin_bottom = 5
	return s

# ─── Load / display levels ────────────────────────────────────────────────────

func _load_custom_levels() -> void:
	var grid = $MarginContainer/ContentCard/CardInner/VBoxContainer/ScrollContainer/GridContainer
	var custom_levels_path := "user://custom_levels/"

	if not DirAccess.dir_exists_absolute(custom_levels_path):
		_show_empty_label(grid)
		return

	var dir := DirAccess.open(custom_levels_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		var level_count := 0

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				_create_level_card(custom_levels_path + file_name)
				level_count += 1
			file_name = dir.get_next()

		dir.list_dir_end()

		if level_count == 0:
			_show_empty_label(grid)

func _show_empty_label(parent: Node) -> void:
	var lbl := Label.new()
	lbl.text = "No custom levels found.\nCreate one in the Level Editor!"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.42, 0.55, 0.48, 1))
	parent.add_child(lbl)

func _create_level_card(file_path: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_string) != OK:
		return

	var level_data : Dictionary = json.data
	var level_name : String     = level_data.get("level_name", "Untitled")
	var created    : String     = level_data.get("created_date", "")
	var date_str   : String     = created.split("T")[0] if created.contains("T") else created

	# ── Card shell ────────────────────────────────────────────────────────────
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 195)
	card.add_theme_stylebox_override("panel", _s_card)

	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left",   14)
	inner.add_theme_constant_override("margin_right",  14)
	inner.add_theme_constant_override("margin_top",    12)
	inner.add_theme_constant_override("margin_bottom", 12)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	# Level name
	var name_lbl := Label.new()
	name_lbl.text = level_name
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(0.87, 0.88, 0.96, 1))
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	# Date — small / muted
	var date_lbl := Label.new()
	date_lbl.text = date_str
	date_lbl.add_theme_font_size_override("font_size", 11)
	date_lbl.add_theme_color_override("font_color", Color(0.40, 0.50, 0.58, 1))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# Play button
	var play_btn := Button.new()
	play_btn.text = "Play"
	play_btn.custom_minimum_size = Vector2(0, 36)
	play_btn.add_theme_font_size_override("font_size", 14)
	play_btn.add_theme_stylebox_override("normal",  _s_play)
	play_btn.add_theme_stylebox_override("hover",   _s_play_hv)
	play_btn.add_theme_stylebox_override("pressed", _s_play_hv)
	play_btn.pressed.connect(_on_play_pressed.bind(level_data))

	# Edit button
	var edit_btn := Button.new()
	edit_btn.text = "Edit"
	edit_btn.custom_minimum_size = Vector2(0, 32)
	edit_btn.add_theme_font_size_override("font_size", 13)
	edit_btn.add_theme_stylebox_override("normal",  _s_edit)
	edit_btn.add_theme_stylebox_override("hover",   _s_edit_hv)
	edit_btn.add_theme_stylebox_override("pressed", _s_edit_hv)
	edit_btn.pressed.connect(_on_edit_pressed.bind(file_path))

	# Delete button
	var del_btn := Button.new()
	del_btn.text = "Delete"
	del_btn.custom_minimum_size = Vector2(0, 32)
	del_btn.add_theme_font_size_override("font_size", 13)
	del_btn.add_theme_color_override("font_color",       Color(0.72, 0.40, 0.36, 1))
	del_btn.add_theme_color_override("font_hover_color", Color(1.0,  0.80, 0.78, 1))
	del_btn.add_theme_stylebox_override("normal",  _s_del)
	del_btn.add_theme_stylebox_override("hover",   _s_del_hv)
	del_btn.add_theme_stylebox_override("pressed", _s_del_hv)
	del_btn.pressed.connect(_on_delete_pressed.bind(file_path))

	vbox.add_child(name_lbl)
	vbox.add_child(date_lbl)
	vbox.add_child(spacer)
	vbox.add_child(play_btn)
	vbox.add_child(edit_btn)
	vbox.add_child(del_btn)
	inner.add_child(vbox)
	card.add_child(inner)

	var grid = $MarginContainer/ContentCard/CardInner/VBoxContainer/ScrollContainer/GridContainer
	grid.add_child(card)

# ─── Callbacks ────────────────────────────────────────────────────────────────

func _on_play_pressed(level_data: Dictionary) -> void:
	level_data["level_id"] = 999
	get_tree().root.set_meta("custom_level", level_data)
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_edit_pressed(file_path: String) -> void:
	get_tree().root.set_meta("edit_level_path", file_path)
	get_tree().change_scene_to_file("res://scenes/ui/level_editor.tscn")

func _on_delete_pressed(file_path: String) -> void:
	pending_delete_path = file_path
	var file_name := file_path.get_file().get_basename().replace("_", " ").capitalize()
	$DeleteConfirmDialog.dialog_text = "Are you sure you want to delete '%s'?\nThis cannot be undone!" % file_name
	$DeleteConfirmDialog.popup_centered()

func _on_delete_confirmed() -> void:
	if pending_delete_path == "":
		return
	if DirAccess.remove_absolute(pending_delete_path) == OK:
		pending_delete_path = ""
		_refresh_list()
	else:
		push_error("Failed to delete level: ", pending_delete_path)
		pending_delete_path = ""

func _on_refresh_pressed() -> void:
	_refresh_list()

func _refresh_list() -> void:
	_clear_grid()
	_load_custom_levels()

func _clear_grid() -> void:
	var grid = $MarginContainer/ContentCard/CardInner/VBoxContainer/ScrollContainer/GridContainer
	for child in grid.get_children():
		child.queue_free()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
