## Custom levels screen — nature-tech theme, dynamically built level cards.
extends Control

const PER_PAGE := 20

var pending_delete_path: String = ""
var _current_tab: String = "local"
var _community_page: int = 0
var _is_loading: bool = false

# Shared styles built once
var _s_card    : StyleBoxFlat
var _s_play    : StyleBoxFlat
var _s_play_hv : StyleBoxFlat
var _s_edit    : StyleBoxFlat
var _s_edit_hv : StyleBoxFlat
var _s_del     : StyleBoxFlat
var _s_del_hv  : StyleBoxFlat
var _s_tab_active   : StyleBoxFlat
var _s_tab_inactive : StyleBoxFlat

@onready var _tab_local_btn       = $MarginContainer/ContentCard/CardInner/VBoxContainer/TabRow/MyLevelsTabBtn
@onready var _tab_community_btn   = $MarginContainer/ContentCard/CardInner/VBoxContainer/TabRow/CommunityTabBtn
@onready var _status_label        = $MarginContainer/ContentCard/CardInner/VBoxContainer/StatusLabel
@onready var _load_more_container = $MarginContainer/ContentCard/CardInner/VBoxContainer/LoadMoreContainer
@onready var _load_more_btn       = $MarginContainer/ContentCard/CardInner/VBoxContainer/LoadMoreContainer/LoadMoreButton
@onready var _subtitle_label      = $MarginContainer/ContentCard/CardInner/VBoxContainer/SubtitleLabel
@onready var _refresh_button      = $MarginContainer/ContentCard/CardInner/VBoxContainer/ButtonContainer/RefreshButton

func _ready() -> void:
	_build_styles()
	$MarginContainer/ContentCard/CardInner/VBoxContainer/ButtonContainer/BackButton.pressed.connect(_on_back_pressed)
	_refresh_button.pressed.connect(_on_refresh_pressed)
	$DeleteConfirmDialog.confirmed.connect(_on_delete_confirmed)
	_tab_local_btn.pressed.connect(func(): _switch_tab("local"))
	_tab_community_btn.pressed.connect(func(): _switch_tab("community"))
	_load_more_btn.pressed.connect(_on_load_more)
	_apply_tab_styles()
	_switch_tab("local")

# ─── Tab switching ────────────────────────────────────────────────────────────

func _switch_tab(tab: String) -> void:
	_current_tab = tab
	_apply_tab_styles()
	_clear_grid()
	_load_more_container.visible = false
	_set_status("", true)

	if tab == "local":
		_subtitle_label.text = "Your crafted puzzles"
		_refresh_button.visible = true
		_load_custom_levels()
	else:
		_subtitle_label.text = "Community puzzles"
		_refresh_button.visible = false
		_community_page = 0
		_load_community_levels()

func _apply_tab_styles() -> void:
	_tab_local_btn.add_theme_stylebox_override("normal",
		_s_tab_active if _current_tab == "local" else _s_tab_inactive)
	_tab_local_btn.add_theme_stylebox_override("hover",
		_s_tab_active if _current_tab == "local" else _s_tab_inactive)
	_tab_community_btn.add_theme_stylebox_override("normal",
		_s_tab_active if _current_tab == "community" else _s_tab_inactive)
	_tab_community_btn.add_theme_stylebox_override("hover",
		_s_tab_active if _current_tab == "community" else _s_tab_inactive)

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
	_s_play    = _make_flat(Color(0.075, 0.455, 0.216, 1), Color(0, 0, 0, 0),             0, 5)
	_s_play_hv = _make_flat(Color(0.098, 0.576, 0.271, 1), Color(0, 0, 0, 0),             0, 5)

	# Edit — neutral dark
	_s_edit    = _make_flat(Color(0.063, 0.075, 0.118, 1), Color(0.165, 0.196, 0.306, 1), 1, 5)
	_s_edit_hv = _make_flat(Color(0.071, 0.110, 0.082, 1), Color(0.22,  0.58,  0.32,  1), 1, 5)

	# Delete — danger
	_s_del    = _make_flat(Color(0.145, 0.063, 0.039, 1), Color(0.306, 0.110, 0.078, 1), 1, 5)
	_s_del_hv = _make_flat(Color(0.576, 0.129, 0.082, 1), Color(0.780, 0.176, 0.110, 1), 1, 5)

	# Tab — active (green) / inactive (dark border)
	_s_tab_active   = _make_flat(Color(0.075, 0.455, 0.216, 1), Color(0, 0, 0, 0),             0, 6)
	_s_tab_inactive = _make_flat(Color(0.047, 0.055, 0.082, 1), Color(0.165, 0.196, 0.306, 1), 1, 6)
	for s in [_s_tab_active, _s_tab_inactive]:
		s.content_margin_left   = 12
		s.content_margin_right  = 12
		s.content_margin_top    = 8
		s.content_margin_bottom = 8

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

# ─── Local levels ─────────────────────────────────────────────────────────────

func _load_custom_levels() -> void:
	var grid = _get_grid()
	var custom_levels_path := "user://custom_levels/"

	if not DirAccess.dir_exists_absolute(custom_levels_path):
		_show_empty_label(grid, "No custom levels found.\nCreate one in the Level Editor!")
		return

	var dir := DirAccess.open(custom_levels_path)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		var level_count := 0

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".json"):
				_create_local_card(custom_levels_path + file_name)
				level_count += 1
			file_name = dir.get_next()

		dir.list_dir_end()

		if level_count == 0:
			_show_empty_label(grid, "No custom levels found.\nCreate one in the Level Editor!")

func _create_local_card(file_path: String) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		file.close()
		return
	file.close()

	var level_data : Dictionary = json.data
	var level_name : String     = level_data.get("level_name", "Untitled")
	var created    : String     = level_data.get("created_date", "")
	var date_str   : String     = created.split("T")[0] if created.contains("T") else created

	var card := _make_card_shell()
	var vbox := card.get_child(0).get_child(0)  # MarginContainer → VBoxContainer

	vbox.add_child(_make_name_label(level_name))
	var sub := _make_sub_label(date_str)
	vbox.add_child(sub)
	vbox.add_child(_make_spacer())

	var play_btn := _make_button("Play", _s_play, _s_play_hv)
	play_btn.pressed.connect(_on_play_local_pressed.bind(level_data))
	vbox.add_child(play_btn)

	var edit_btn := _make_button("Edit", _s_edit, _s_edit_hv)
	edit_btn.pressed.connect(_on_edit_pressed.bind(file_path))
	vbox.add_child(edit_btn)

	var del_btn := _make_button("Delete", _s_del, _s_del_hv)
	del_btn.add_theme_color_override("font_color",       Color(0.72, 0.40, 0.36, 1))
	del_btn.add_theme_color_override("font_hover_color", Color(1.0,  0.80, 0.78, 1))
	del_btn.pressed.connect(_on_delete_pressed.bind(file_path))
	vbox.add_child(del_btn)

	_get_grid().add_child(card)

# ─── Community levels ─────────────────────────────────────────────────────────

func _load_community_levels() -> void:
	if _is_loading:
		return
	_is_loading = true
	_set_status("Loading…", true)
	_load_more_container.visible = false

	var levels : Array = await ApiClient.get_community_levels(_community_page, PER_PAGE)

	_is_loading = false

	if levels.is_empty() and _community_page == 0:
		_show_empty_label(_get_grid(), "No community levels yet.\nBe the first to publish one!")
		return

	for level in levels:
		_create_community_card(level)

	_set_status("", true)
	# Show Load More only if a full page came back (there may be more)
	_load_more_container.visible = (levels.size() >= PER_PAGE)

func _create_community_card(level: Dictionary) -> void:
	var level_name  : String = level.get("name", "Untitled")
	var author      : String = ""
	var profiles = level.get("profiles", null)
	if profiles is Dictionary:
		author = profiles.get("username", "")
	var solve_count : int = level.get("solve_count", 0)
	var level_id    : String = str(level.get("id", ""))

	var card := _make_card_shell()
	var vbox := card.get_child(0).get_child(0)

	vbox.add_child(_make_name_label(level_name))

	if author != "":
		var author_lbl := _make_sub_label("by " + author)
		vbox.add_child(author_lbl)

	var solves_lbl := _make_sub_label("%d solve%s" % [solve_count, "s" if solve_count != 1 else ""])
	vbox.add_child(solves_lbl)

	vbox.add_child(_make_spacer())

	var play_btn := _make_button("Play", _s_play, _s_play_hv)
	play_btn.pressed.connect(_on_play_community_pressed.bind(level_id, play_btn))
	vbox.add_child(play_btn)

	_get_grid().add_child(card)

func _on_load_more() -> void:
	_community_page += 1
	_load_community_levels()

# ─── Card widget helpers ──────────────────────────────────────────────────────

func _make_card_shell() -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(200, 180)
	card.add_theme_stylebox_override("panel", _s_card)

	var inner := MarginContainer.new()
	inner.add_theme_constant_override("margin_left",   14)
	inner.add_theme_constant_override("margin_right",  14)
	inner.add_theme_constant_override("margin_top",    12)
	inner.add_theme_constant_override("margin_bottom", 12)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)

	inner.add_child(vbox)
	card.add_child(inner)
	return card

func _make_name_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 15)
	lbl.add_theme_color_override("font_color", Color(0.87, 0.88, 0.96, 1))
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return lbl

func _make_sub_label(text: String) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.40, 0.50, 0.58, 1))
	return lbl

func _make_spacer() -> Control:
	var s := Control.new()
	s.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return s

func _make_button(label: String, normal: StyleBoxFlat, hover: StyleBoxFlat) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(0, 34)
	btn.add_theme_font_size_override("font_size", 13)
	btn.add_theme_stylebox_override("normal",  normal)
	btn.add_theme_stylebox_override("hover",   hover)
	btn.add_theme_stylebox_override("pressed", hover)
	return btn

func _show_empty_label(parent: Node, msg: String) -> void:
	var lbl := Label.new()
	lbl.text = msg
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(0.42, 0.55, 0.48, 1))
	parent.add_child(lbl)

func _set_status(msg: String, ok: bool) -> void:
	_status_label.text    = msg
	_status_label.visible = msg != ""
	var color := Color(0.40, 0.90, 0.55, 1) if ok else Color(0.95, 0.38, 0.38, 1)
	_status_label.add_theme_color_override("font_color", color)

func _get_grid() -> GridContainer:
	return $MarginContainer/ContentCard/CardInner/VBoxContainer/ScrollContainer/GridContainer

# ─── Callbacks — local levels ─────────────────────────────────────────────────

func _on_play_local_pressed(level_data: Dictionary) -> void:
	# Local saved levels don't have a UUID — mark the source so the game knows.
	level_data["level_source"] = "local"
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

# ─── Callbacks — community levels ─────────────────────────────────────────────

func _on_play_community_pressed(level_id: String, btn: Button) -> void:
	btn.disabled = true
	btn.text = "Loading…"

	var level_data : Dictionary = await ApiClient.get_level(level_id)

	if level_data.is_empty() or level_data.has("error"):
		btn.disabled = false
		btn.text = "Play"
		_set_status("Failed to load level. Try again.", false)
		return

	# Community levels carry a real UUID — keep it so we can submit to the
	# correct leaderboard and let the player restart the level later.
	level_data["level_source"] = "community"
	get_tree().root.set_meta("custom_level", level_data)
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

# ─── Shared callbacks ─────────────────────────────────────────────────────────

func _on_refresh_pressed() -> void:
	_refresh_list()

func _refresh_list() -> void:
	_clear_grid()
	_load_more_container.visible = false
	if _current_tab == "local":
		_load_custom_levels()
	else:
		_community_page = 0
		_load_community_levels()

func _clear_grid() -> void:
	for child in _get_grid().get_children():
		child.queue_free()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
