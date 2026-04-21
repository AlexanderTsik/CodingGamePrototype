## Level select screen — nature-tech theme, dynamically built level cards.
extends Control

var level_definitions: Node

# Shared styles (built once, shared across all level cards)
var _s_card_easy   : StyleBoxFlat
var _s_card_medium : StyleBoxFlat
var _s_card_hard   : StyleBoxFlat
var _s_btn_play    : StyleBoxFlat
var _s_btn_play_hv : StyleBoxFlat

func _ready() -> void:
	_build_styles()
	level_definitions = load("res://scripts/levels/level_definitions.gd").new()
	$MarginContainer/ContentCard/CardInner/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)
	_create_level_buttons()

# ─── Style builders ───────────────────────────────────────────────────────────

func _build_styles() -> void:
	_s_card_easy   = _make_card(Color(0.18, 0.48, 0.28, 0.75))
	_s_card_medium = _make_card(Color(0.68, 0.52, 0.18, 0.75))
	_s_card_hard   = _make_card(Color(0.55, 0.18, 0.18, 0.75))

	_s_btn_play = StyleBoxFlat.new()
	_s_btn_play.bg_color = Color(0.075, 0.455, 0.216, 1)
	_s_btn_play.corner_radius_top_left     = 6
	_s_btn_play.corner_radius_top_right    = 6
	_s_btn_play.corner_radius_bottom_right = 6
	_s_btn_play.corner_radius_bottom_left  = 6
	_s_btn_play.content_margin_left   = 8
	_s_btn_play.content_margin_right  = 8
	_s_btn_play.content_margin_top    = 6
	_s_btn_play.content_margin_bottom = 6

	_s_btn_play_hv = StyleBoxFlat.new()
	_s_btn_play_hv.bg_color = Color(0.098, 0.576, 0.271, 1)
	_s_btn_play_hv.corner_radius_top_left     = 6
	_s_btn_play_hv.corner_radius_top_right    = 6
	_s_btn_play_hv.corner_radius_bottom_right = 6
	_s_btn_play_hv.corner_radius_bottom_left  = 6
	_s_btn_play_hv.content_margin_left   = 8
	_s_btn_play_hv.content_margin_right  = 8
	_s_btn_play_hv.content_margin_top    = 6
	_s_btn_play_hv.content_margin_bottom = 6

func _make_card(border_col: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.055, 0.063, 0.100, 0.95)
	s.border_width_left   = 1
	s.border_width_top    = 1
	s.border_width_right  = 1
	s.border_width_bottom = 1
	s.border_color = border_col
	s.corner_radius_top_left     = 8
	s.corner_radius_top_right    = 8
	s.corner_radius_bottom_right = 8
	s.corner_radius_bottom_left  = 8
	s.shadow_color  = Color(0, 0, 0, 0.40)
	s.shadow_size   = 8
	s.shadow_offset = Vector2(0, 4)
	return s

# ─── Build level grid ─────────────────────────────────────────────────────────

func _create_level_buttons() -> void:
	var grid = $MarginContainer/ContentCard/CardInner/VBoxContainer/ScrollContainer/GridContainer
	var level_count : int = level_definitions.get_level_count()

	for i in range(level_count):
		var level_id  := i + 1
		var level_def : Dictionary = level_definitions.get_level(level_id)
		var difficulty : int = level_def.get("difficulty", 1)

		# ── Card shell ──────────────────────────────────────────────────────
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(200, 145)
		match difficulty:
			1: card.add_theme_stylebox_override("panel", _s_card_easy)
			2: card.add_theme_stylebox_override("panel", _s_card_medium)
			_: card.add_theme_stylebox_override("panel", _s_card_hard)

		var inner := MarginContainer.new()
		inner.add_theme_constant_override("margin_left",   14)
		inner.add_theme_constant_override("margin_right",  14)
		inner.add_theme_constant_override("margin_top",    12)
		inner.add_theme_constant_override("margin_bottom", 12)

		var vbox := VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 5)

		# Level number — small / muted
		var num_lbl := Label.new()
		num_lbl.text = "Level %d" % level_id
		num_lbl.add_theme_font_size_override("font_size", 11)
		num_lbl.add_theme_color_override("font_color", Color(0.42, 0.50, 0.60, 1))

		# Level name
		var name_lbl := Label.new()
		name_lbl.text = level_def["level_name"]
		name_lbl.add_theme_font_size_override("font_size", 15)
		name_lbl.add_theme_color_override("font_color", Color(0.87, 0.88, 0.96, 1))
		name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

		# Difficulty badge
		var diff_lbl := Label.new()
		diff_lbl.add_theme_font_size_override("font_size", 12)
		match difficulty:
			1:
				diff_lbl.text = "Easy"
				diff_lbl.add_theme_color_override("font_color", Color(0.38, 0.82, 0.48, 1))
			2:
				diff_lbl.text = "Medium"
				diff_lbl.add_theme_color_override("font_color", Color(0.90, 0.72, 0.28, 1))
			_:
				diff_lbl.text = "Hard"
				diff_lbl.add_theme_color_override("font_color", Color(0.90, 0.38, 0.38, 1))

		var spacer := Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# Play button
		var play_btn := Button.new()
		play_btn.text = "Play"
		play_btn.add_theme_font_size_override("font_size", 14)
		play_btn.add_theme_stylebox_override("normal",  _s_btn_play)
		play_btn.add_theme_stylebox_override("hover",   _s_btn_play_hv)
		play_btn.add_theme_stylebox_override("pressed", _s_btn_play_hv)
		play_btn.pressed.connect(_on_level_pressed.bind(level_id))

		vbox.add_child(num_lbl)
		vbox.add_child(name_lbl)
		vbox.add_child(diff_lbl)
		vbox.add_child(spacer)
		vbox.add_child(play_btn)
		inner.add_child(vbox)
		card.add_child(inner)
		grid.add_child(card)

# ─── Callbacks ────────────────────────────────────────────────────────────────

func _on_level_pressed(level_id: int) -> void:
	get_tree().root.set_meta("selected_level", level_id)
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
