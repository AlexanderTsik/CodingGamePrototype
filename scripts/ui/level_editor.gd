## Level editor — nature-tech theme applied via _apply_theme().
extends Control

# Cell types enum reference
const CellType = preload("res://scripts/core/cell_types.gd")

# Current selected cell type to place
var current_cell_type = CellType.Type.WALL

# Grid data with adjustable size
var grid_data = []
var grid_width = 10
var grid_height = 10
const MIN_GRID_SIZE = 3
const MAX_GRID_SIZE = 15

# Grid manager and renderer
var grid_manager: Node
var grid_renderer: Control

# UI References
@onready var grid_background     = $HSplitContainer/EditorPanel/CenterContainer/GridBackground
@onready var save_dialog         = $SaveDialog
@onready var load_dialog         = $LoadDialog
@onready var name_input          = $SaveDialog/MarginContainer/VBoxContainer/NameInput
@onready var hint_input          = $SaveDialog/MarginContainer/VBoxContainer/HintInput
@onready var starter_code_input  = $SaveDialog/MarginContainer/VBoxContainer/StarterCodeInput
@onready var width_spinbox       = $HSplitContainer/ToolPanel/VBoxContainer/WidthContainer/WidthSpinBox
@onready var height_spinbox      = $HSplitContainer/ToolPanel/VBoxContainer/HeightContainer/HeightSpinBox
@onready var publish_button      = $HSplitContainer/ToolPanel/VBoxContainer/PublishButton
@onready var publish_status_label = $HSplitContainer/ToolPanel/VBoxContainer/PublishStatusLabel

# Current level metadata
var current_level_name = ""
var current_level_file = ""
var _save_status_label: Label  # inline validation feedback inside the save dialog

func _ready():
	# Initialize grid data
	_initialize_grid()

	# Load grid manager
	grid_manager = load("res://scripts/core/grid_manager.gd").new()
	add_child(grid_manager)

	# Create an initial empty layout string and load it
	var empty_layout = _grid_to_string()
	grid_manager.load_level_from_string(empty_layout)

	# Set up grid renderer
	grid_renderer = grid_background
	grid_renderer.grid_manager = grid_manager
	grid_renderer.refresh()

	# Connect cell type buttons
	$HSplitContainer/ToolPanel/VBoxContainer/EmptyButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.EMPTY))
	$HSplitContainer/ToolPanel/VBoxContainer/WallButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.WALL))
	$HSplitContainer/ToolPanel/VBoxContainer/HazardButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.HAZARD))
	$HSplitContainer/ToolPanel/VBoxContainer/GoalButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.GOAL))
	$HSplitContainer/ToolPanel/VBoxContainer/StartButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.START))
	$HSplitContainer/ToolPanel/VBoxContainer/TeleporterButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.TELEPORTER))
	$HSplitContainer/ToolPanel/VBoxContainer/WaterButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.WATER))
	$HSplitContainer/ToolPanel/VBoxContainer/LavaButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.LAVA))
	$HSplitContainer/ToolPanel/VBoxContainer/IceButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.ICE))
	$HSplitContainer/ToolPanel/VBoxContainer/SwitchButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.SWITCH))
	$HSplitContainer/ToolPanel/VBoxContainer/DoorButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.DOOR))
	$HSplitContainer/ToolPanel/VBoxContainer/KeyButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.KEY))
	$HSplitContainer/ToolPanel/VBoxContainer/CoinButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.COIN))
	$HSplitContainer/ToolPanel/VBoxContainer/GemButton.pressed.connect(_on_cell_type_selected.bind(CellType.Type.GEM))

	# Connect action buttons
	$HSplitContainer/ToolPanel/VBoxContainer/ResizeButton.pressed.connect(_on_resize_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/ClearButton.pressed.connect(_on_clear_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/SaveButton.pressed.connect(_on_save_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/LoadButton.pressed.connect(_on_load_pressed)

	# The native file dialog behind Load doesn't work in HTML5 exports; on web,
	# local levels are loaded from the Custom Levels screen instead.
	if OS.has_feature("web"):
		$HSplitContainer/ToolPanel/VBoxContainer/LoadButton.hide()
	$HSplitContainer/ToolPanel/VBoxContainer/TestButton.pressed.connect(_on_test_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	publish_button.pressed.connect(_on_publish_pressed)

	# Connect save dialog buttons
	$SaveDialog/MarginContainer/VBoxContainer/ButtonContainer/ConfirmButton.pressed.connect(_on_save_confirmed)
	$SaveDialog/MarginContainer/VBoxContainer/ButtonContainer/CancelButton.pressed.connect(_on_save_cancelled)

	# Inline validation status label, placed just above the dialog's buttons
	_save_status_label = Label.new()
	_save_status_label.add_theme_font_size_override("font_size", 12)
	_save_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_save_status_label.visible = false
	var _save_vbox = $SaveDialog/MarginContainer/VBoxContainer
	_save_vbox.add_child(_save_status_label)
	_save_vbox.move_child(_save_status_label, _save_vbox.get_child_count() - 2)

	# Connect load dialog
	load_dialog.file_selected.connect(_on_file_selected)

	# Enable mouse input for grid
	grid_background.gui_input.connect(_on_grid_input)

	# Initialize spinbox values
	width_spinbox.value = grid_width
	height_spinbox.value = grid_height

	# Apply visual theme
	_apply_theme()

	# Check if editing an existing level
	await get_tree().process_frame
	if get_tree().root.has_meta("edit_level_path"):
		var file_path = get_tree().root.get_meta("edit_level_path")
		get_tree().root.remove_meta("edit_level_path")
		_load_level_from_path(file_path)

# ─── Theme ────────────────────────────────────────────────────────────────────

func _apply_theme() -> void:
	# Shared button styles
	var s_normal := _make_btn(Color(0.063, 0.075, 0.118, 1), Color(0.165, 0.196, 0.306, 1), 1, 4)
	var s_hover  := _make_btn(Color(0.071, 0.110, 0.082, 1), Color(0.22,  0.58,  0.32,  1), 1, 4)
	var s_prim   := _make_btn(Color(0.075, 0.455, 0.216, 1), Color(0, 0, 0, 0),             0, 4)
	var s_prim_h := _make_btn(Color(0.098, 0.576, 0.271, 1), Color(0, 0, 0, 0),             0, 4)
	var s_dng    := _make_btn(Color(0.145, 0.063, 0.039, 1), Color(0.306, 0.110, 0.078, 1), 1, 4)
	var s_dng_h  := _make_btn(Color(0.576, 0.129, 0.082, 1), Color(0.780, 0.176, 0.110, 1), 1, 4)

	# Title
	var title := $HSplitContainer/ToolPanel/VBoxContainer/TitleLabel as Label
	title.add_theme_color_override("font_color", Color(0.94, 0.76, 0.26, 1))

	# Section labels
	var muted := Color(0.42, 0.55, 0.50, 1)
	for path in [
		"HSplitContainer/ToolPanel/VBoxContainer/CellTypeLabel",
		"HSplitContainer/ToolPanel/VBoxContainer/GridSizeLabel",
		"HSplitContainer/ToolPanel/VBoxContainer/WidthContainer/WidthLabel",
		"HSplitContainer/ToolPanel/VBoxContainer/HeightContainer/HeightLabel",
	]:
		var lbl := get_node(path) as Label
		if lbl:
			lbl.add_theme_color_override("font_color", muted)

	# Separators
	for path in [
		"HSplitContainer/ToolPanel/VBoxContainer/HSeparator",
		"HSplitContainer/ToolPanel/VBoxContainer/HSeparator2",
		"HSplitContainer/ToolPanel/VBoxContainer/HSeparator2a",
		"HSplitContainer/ToolPanel/VBoxContainer/HSeparator3",
	]:
		var sep := get_node(path) as HSeparator
		if sep:
			sep.add_theme_color_override("separator", Color(0.18, 0.42, 0.25, 0.40))

	# Cell type buttons — color-coded left-border indicator per type
	var cell_btns := {
		"EmptyButton":      Color(0.32, 0.38, 0.48, 1),
		"WallButton":       Color(0.42, 0.46, 0.58, 1),
		"HazardButton":     Color(0.82, 0.22, 0.22, 1),
		"GoalButton":       Color(0.22, 0.74, 0.36, 1),
		"StartButton":      Color(0.90, 0.70, 0.15, 1),
		"TeleporterButton": Color(0.62, 0.22, 0.88, 1),
		"WaterButton":      Color(0.22, 0.52, 0.90, 1),
		"LavaButton":       Color(0.90, 0.40, 0.12, 1),
		"IceButton":        Color(0.62, 0.88, 0.96, 1),
		"SwitchButton":     Color(0.78, 0.90, 0.22, 1),
		"DoorButton":       Color(0.65, 0.38, 0.14, 1),
		"KeyButton":        Color(0.92, 0.76, 0.20, 1),
		"CoinButton":       Color(0.96, 0.82, 0.22, 1),
		"GemButton":        Color(0.22, 0.88, 0.86, 1),
	}
	for btn_name in cell_btns:
		var btn := get_node("HSplitContainer/ToolPanel/VBoxContainer/" + btn_name) as Button
		if btn:
			var col : Color = cell_btns[btn_name]
			btn.add_theme_stylebox_override("normal",  _make_cell_style(col, false))
			btn.add_theme_stylebox_override("hover",   _make_cell_style(col, true))
			btn.add_theme_stylebox_override("pressed", _make_cell_style(col, true))
			btn.add_theme_color_override("font_color", Color(0.82, 0.86, 0.94, 1))
			btn.add_theme_font_size_override("font_size", 13)

	# Action buttons
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/ResizeButton",   s_normal, s_hover)
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/LoadButton",    s_normal, s_hover)
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/MenuButton",    s_normal, s_hover)
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/SaveButton",    s_prim,   s_prim_h)
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/TestButton",    s_prim,   s_prim_h)
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/PublishButton", s_prim,   s_prim_h)
	_style_btn("HSplitContainer/ToolPanel/VBoxContainer/ClearButton",   s_dng,    s_dng_h)

	var clear_btn := get_node("HSplitContainer/ToolPanel/VBoxContainer/ClearButton") as Button
	if clear_btn:
		clear_btn.add_theme_color_override("font_color",       Color(0.72, 0.40, 0.36, 1))
		clear_btn.add_theme_color_override("font_hover_color", Color(1.0,  0.80, 0.78, 1))

func _style_btn(path: String, normal: StyleBoxFlat, hover: StyleBoxFlat) -> void:
	var btn := get_node(path) as Button
	if btn:
		btn.add_theme_stylebox_override("normal",  normal)
		btn.add_theme_stylebox_override("hover",   hover)
		btn.add_theme_stylebox_override("pressed", hover)

func _make_btn(bg: Color, border: Color, bw: int, cr: int) -> StyleBoxFlat:
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
	s.content_margin_top    = 4
	s.content_margin_bottom = 4
	return s

func _make_cell_style(indicator: Color, hovered: bool) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.071, 0.110, 0.082, 1) if hovered else Color(0.047, 0.055, 0.082, 1)
	s.border_width_left   = 3
	s.border_width_top    = 0
	s.border_width_right  = 0
	s.border_width_bottom = 0
	s.border_color = indicator
	s.corner_radius_top_left     = 4
	s.corner_radius_top_right    = 4
	s.corner_radius_bottom_right = 4
	s.corner_radius_bottom_left  = 4
	s.content_margin_left   = 10
	s.content_margin_right  = 8
	s.content_margin_top    = 4
	s.content_margin_bottom = 4
	return s

# ─── Grid logic ───────────────────────────────────────────────────────────────

func _initialize_grid():
	grid_data = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(CellType.Type.EMPTY)
		grid_data.append(row)

func _on_grid_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and (event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT):
			var grid_pos = _get_grid_position(event.position)
			if grid_pos != Vector2i(-1, -1):
				if event.button_index == MOUSE_BUTTON_LEFT:
					_place_cell(grid_pos)
				else:
					_erase_cell(grid_pos)
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			var grid_pos = _get_grid_position(event.position)
			if grid_pos != Vector2i(-1, -1):
				_place_cell(grid_pos)
		elif event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			var grid_pos = _get_grid_position(event.position)
			if grid_pos != Vector2i(-1, -1):
				_erase_cell(grid_pos)

func _get_grid_position(mouse_pos: Vector2) -> Vector2i:
	var cell_size = grid_manager.tile_size if grid_manager and grid_manager.tile_size > 0 else 48
	# The grid is centred inside the renderer, so subtract its offset first.
	var off = grid_renderer.get("grid_offset") if grid_renderer else null
	var ox: float = off.x if off is Vector2 else 0.0
	var oy: float = off.y if off is Vector2 else 0.0
	var grid_x = int((mouse_pos.x - ox) / cell_size)
	var grid_y = int((mouse_pos.y - oy) / cell_size)
	if grid_x >= 0 and grid_x < grid_width and grid_y >= 0 and grid_y < grid_height:
		return Vector2i(grid_x, grid_y)
	return Vector2i(-1, -1)

func _place_cell(grid_pos: Vector2i):
	if current_cell_type == CellType.Type.START:
		_remove_all_start_positions()
	grid_data[grid_pos.y][grid_pos.x] = current_cell_type
	_update_grid_manager()

func _erase_cell(grid_pos: Vector2i):
	grid_data[grid_pos.y][grid_pos.x] = CellType.Type.EMPTY
	_update_grid_manager()

func _remove_all_start_positions():
	for y in range(grid_height):
		for x in range(grid_width):
			if grid_data[y][x] == CellType.Type.START:
				grid_data[y][x] = CellType.Type.EMPTY

func _update_grid_manager():
	var layout = _grid_to_string()
	grid_manager.load_level_from_string(layout)
	grid_renderer.refresh()

func _on_cell_type_selected(cell_type):
	current_cell_type = cell_type

# ─── Action handlers ──────────────────────────────────────────────────────────

func _on_clear_pressed():
	_initialize_grid()
	_update_grid_manager()

func _on_resize_pressed():
	var new_width  = clampi(int(width_spinbox.value),  MIN_GRID_SIZE, MAX_GRID_SIZE)
	var new_height = clampi(int(height_spinbox.value), MIN_GRID_SIZE, MAX_GRID_SIZE)

	var old_data   = grid_data.duplicate(true)
	var old_width  = grid_width
	var old_height = grid_height

	grid_width  = new_width
	grid_height = new_height
	_initialize_grid()

	for y in range(min(old_height, grid_height)):
		for x in range(min(old_width, grid_width)):
			grid_data[y][x] = old_data[y][x]

	_update_grid_manager()

func _on_save_pressed():
	name_input.text = current_level_name if current_level_name != "" else "My Custom Level"
	_save_status_label.visible = false
	save_dialog.visible = true

func _on_save_confirmed():
	var level_name = name_input.text.strip_edges()
	if level_name == "":
		_show_save_status("Level name cannot be empty.")
		return

	# Same Start/Goal check as Publish — a level with no start or goal would
	# spawn the player in a wall or be impossible to win.
	var validation_err := _validate_for_publish()
	if validation_err != "":
		_show_save_status(validation_err + " before saving.")
		return

	var level_data = {
		"level_name":    level_name,
		"layout":        _grid_to_string(),
		"hint_text":     hint_input.text,
		"starter_code":  starter_code_input.text,
		"created_date":  Time.get_datetime_string_from_system()
	}

	var save_path := "user://custom_levels/"
	DirAccess.make_dir_absolute(save_path)

	var file_name : String = level_name.to_lower().replace(" ", "_") + ".json"
	var full_path : String = save_path + file_name

	var file := FileAccess.open(full_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(level_data, "\t"))
		file.close()
		current_level_name = level_name
		current_level_file = full_path
		save_dialog.visible = false
	else:
		push_error("Failed to save level!")

func _on_save_cancelled():
	save_dialog.visible = false

func _on_load_pressed():
	var custom_levels_path = OS.get_user_data_dir() + "/custom_levels"
	load_dialog.current_dir = custom_levels_path
	load_dialog.visible = true

func _on_file_selected(path: String):
	_load_level_from_path(path)

func _load_level_from_path(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string := file.get_as_text()
		file.close()
		var json := JSON.new()
		if json.parse(json_string) == OK:
			_load_level_data(json.data)
			current_level_file = path
		else:
			push_error("Failed to parse level file!")
	else:
		push_error("Failed to load level file!")

func _load_level_data(level_data: Dictionary):
	current_level_name = level_data.get("level_name", "")
	_string_to_grid(level_data.get("layout", ""))
	_update_grid_manager()

# ─── Layout string serialisation ──────────────────────────────────────────────

func _grid_to_string() -> String:
	var result = ""
	for y in range(grid_height):
		for x in range(grid_width):
			result += CellType.to_char(grid_data[y][x])
		result += "\n"
	return result.trim_suffix("\n")

func _string_to_grid(layout: String):
	var lines = layout.split("\n")
	var filtered_lines: Array[String] = []
	for line in lines:
		if line.strip_edges() != "":
			filtered_lines.append(line)

	if filtered_lines.size() > 0:
		grid_height = min(filtered_lines.size(), MAX_GRID_SIZE)
		grid_width  = min(filtered_lines[0].length(), MAX_GRID_SIZE)

	_initialize_grid()

	for y in range(min(filtered_lines.size(), grid_height)):
		var line = filtered_lines[y]
		for x in range(min(line.length(), grid_width)):
			grid_data[y][x] = CellType.from_char(line[x])

	width_spinbox.value  = grid_width
	height_spinbox.value = grid_height

# ─── Test / menu ──────────────────────────────────────────────────────────────

func _on_test_pressed():
	var test_level = {
		"level_id":    999,
		"level_name":  "Test: " + (current_level_name if current_level_name != "" else "Untitled"),
		"layout":      _grid_to_string(),
		"starter_code": starter_code_input.text,
		"hint_text":   hint_input.text
	}
	get_tree().root.set_meta("test_level", test_level)
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

# ─── Publish ──────────────────────────────────────────────────────────────────

func _on_publish_pressed() -> void:
	# Must be logged in
	if not AuthManager.is_logged_in():
		_show_publish_status("Log in to publish levels", false)
		return

	# Must have a name (i.e. saved at least once)
	var level_name: String = current_level_name.strip_edges()
	if level_name == "":
		_show_publish_status("Save the level first to give it a name", false)
		return

	# Grid must have a start and a goal
	var err := _validate_for_publish()
	if err != "":
		_show_publish_status(err, false)
		return

	publish_button.disabled = true
	publish_button.text     = "Publishing…"
	publish_status_label.text = ""

	var level_data := {
		"level_name":   level_name,
		"layout":       _grid_to_string(),
		"hint_text":    hint_input.text,
		"starter_code": starter_code_input.text,
	}

	var result = await ApiClient.upload_level(level_data)

	publish_button.disabled = false
	publish_button.text     = "Publish Online"

	if result.has("error"):
		_show_publish_status("Error: " + result.get("msg", str(result["error"])), false)
	else:
		_show_publish_status("Published! ✓", true)

func _validate_for_publish() -> String:
	var has_start := false
	var has_goal  := false
	for y in range(grid_height):
		for x in range(grid_width):
			match grid_data[y][x]:
				CellType.Type.START: has_start = true
				CellType.Type.GOAL:  has_goal  = true
	if not has_start:
		return "Level needs a Start Position"
	if not has_goal:
		return "Level needs a Goal"
	if not GridManager.is_layout_solvable(_grid_to_string()):
		return "The Goal isn't reachable from the Start (check for walls blocking the path)"
	return ""

func _show_save_status(msg: String) -> void:
	_save_status_label.text = msg
	_save_status_label.add_theme_color_override("font_color", Color(0.95, 0.38, 0.38, 1))
	_save_status_label.visible = true

func _show_publish_status(msg: String, ok: bool) -> void:
	publish_status_label.text = msg
	var color := Color(0.40, 0.90, 0.55, 1) if ok else Color(0.95, 0.38, 0.38, 1)
	publish_status_label.add_theme_color_override("font_color", color)
