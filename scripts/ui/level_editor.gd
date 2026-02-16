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
@onready var grid_background = $HSplitContainer/EditorPanel/CenterContainer/GridBackground
@onready var save_dialog = $SaveDialog
@onready var load_dialog = $LoadDialog
@onready var name_input = $SaveDialog/MarginContainer/VBoxContainer/NameInput
@onready var hint_input = $SaveDialog/MarginContainer/VBoxContainer/HintInput
@onready var starter_code_input = $SaveDialog/MarginContainer/VBoxContainer/StarterCodeInput
@onready var width_spinbox = $HSplitContainer/ToolPanel/VBoxContainer/WidthContainer/WidthSpinBox
@onready var height_spinbox = $HSplitContainer/ToolPanel/VBoxContainer/HeightContainer/HeightSpinBox

# Current level metadata
var current_level_name = ""
var current_level_file = ""

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
	
	# Connect action buttons
	$HSplitContainer/ToolPanel/VBoxContainer/ResizeButton.pressed.connect(_on_resize_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/ClearButton.pressed.connect(_on_clear_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/SaveButton.pressed.connect(_on_save_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/LoadButton.pressed.connect(_on_load_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/TestButton.pressed.connect(_on_test_pressed)
	$HSplitContainer/ToolPanel/VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	
	# Connect save dialog buttons
	$SaveDialog/MarginContainer/VBoxContainer/ButtonContainer/ConfirmButton.pressed.connect(_on_save_confirmed)
	$SaveDialog/MarginContainer/VBoxContainer/ButtonContainer/CancelButton.pressed.connect(_on_save_cancelled)
	
	# Connect load dialog
	load_dialog.file_selected.connect(_on_file_selected)
	
	# Enable mouse input for grid
	grid_background.gui_input.connect(_on_grid_input)
	
	# Initialize spinbox values
	width_spinbox.value = grid_width
	height_spinbox.value = grid_height
	
	# Check if editing an existing level
	await get_tree().process_frame
	if get_tree().root.has_meta("edit_level_path"):
		var file_path = get_tree().root.get_meta("edit_level_path")
		get_tree().root.remove_meta("edit_level_path")
		_load_level_from_path(file_path)

func _initialize_grid():
	"""Initialize empty grid"""
	grid_data = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			row.append(CellType.Type.EMPTY)
		grid_data.append(row)

func _on_grid_input(event: InputEvent):
	"""Handle mouse clicks on grid"""
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
	"""Convert mouse position to grid coordinates"""
	var cell_size = 64
	var grid_x = int(mouse_pos.x / cell_size)
	var grid_y = int(mouse_pos.y / cell_size)
	
	if grid_x >= 0 and grid_x < grid_width and grid_y >= 0 and grid_y < grid_height:
		return Vector2i(grid_x, grid_y)
	return Vector2i(-1, -1)

func _place_cell(grid_pos: Vector2i):
	"""Place current cell type at position"""
	# If placing START, remove any existing START positions
	if current_cell_type == CellType.Type.START:
		_remove_all_start_positions()
	
	grid_data[grid_pos.y][grid_pos.x] = current_cell_type
	_update_grid_manager()

func _erase_cell(grid_pos: Vector2i):
	"""Erase cell at position (set to EMPTY)"""
	grid_data[grid_pos.y][grid_pos.x] = CellType.Type.EMPTY
	_update_grid_manager()

func _remove_all_start_positions():
	"""Remove all existing START positions from grid"""
	for y in range(grid_height):
		for x in range(grid_width):
			if grid_data[y][x] == CellType.Type.START:
				grid_data[y][x] = CellType.Type.EMPTY

func _update_grid_manager():
	"""Update grid manager with current grid data"""
	var layout = _grid_to_string()
	grid_manager.load_level_from_string(layout)
	grid_renderer.refresh()

func _on_cell_type_selected(cell_type):
	"""Change current cell type to place"""
	current_cell_type = cell_type
	print("Selected cell type: ", CellType.Type.keys()[cell_type])

func _on_clear_pressed():
	"""Clear the entire grid"""
	_initialize_grid()
	_update_grid_manager()

func _on_resize_pressed():
	"""Resize the grid based on spinbox values"""
	var new_width = int(width_spinbox.value)
	var new_height = int(height_spinbox.value)
	
	# Clamp values to safe range
	new_width = clampi(new_width, MIN_GRID_SIZE, MAX_GRID_SIZE)
	new_height = clampi(new_height, MIN_GRID_SIZE, MAX_GRID_SIZE)
	
	# Save old grid data
	var old_data = grid_data.duplicate(true)
	var old_width = grid_width
	var old_height = grid_height
	
	# Update dimensions
	grid_width = new_width
	grid_height = new_height
	
	# Initialize new grid
	_initialize_grid()
	
	# Copy over existing data where it fits
	for y in range(min(old_height, grid_height)):
		for x in range(min(old_width, grid_width)):
			grid_data[y][x] = old_data[y][x]
	
	# Update grid manager and refresh display
	_update_grid_manager()
	
	print("Grid resized to %dx%d" % [grid_width, grid_height])

func _on_save_pressed():
	"""Open save dialog"""
	name_input.text = current_level_name if current_level_name != "" else "My Custom Level"
	save_dialog.visible = true

func _on_save_confirmed():
	"""Save the level to file"""
	var level_name = name_input.text.strip_edges()
	if level_name == "":
		push_error("Level name cannot be empty!")
		return
	
	# Convert grid data to layout string
	var layout_string = _grid_to_string()
	
	# Create level data
	var level_data = {
		"level_name": level_name,
		"layout": layout_string,
		"hint_text": hint_input.text,
		"starter_code": starter_code_input.text,
		"created_date": Time.get_datetime_string_from_system()
	}
	
	# Save to user data folder
	var save_path = "user://custom_levels/"
	DirAccess.make_dir_absolute(save_path)
	
	var file_name = level_name.to_lower().replace(" ", "_") + ".json"
	var full_path = save_path + file_name
	
	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(level_data, "\t"))
		file.close()
		print("Level saved to: ", full_path)
		current_level_name = level_name
		current_level_file = full_path
		save_dialog.visible = false
	else:
		push_error("Failed to save level!")

func _on_save_cancelled():
	"""Close save dialog without saving"""
	save_dialog.visible = false

func _on_load_pressed():
	"""Open load dialog"""
	var custom_levels_path = OS.get_user_data_dir() + "/custom_levels"
	load_dialog.current_dir = custom_levels_path
	load_dialog.visible = true

func _on_file_selected(path: String):
	"""Load level from file"""
	_load_level_from_path(path)

func _load_level_from_path(path: String):
	"""Load level from file path"""
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var level_data = json.data
			_load_level_data(level_data)
			current_level_file = path
			print("Level loaded from: ", path)
		else:
			push_error("Failed to parse level file!")
	else:
		push_error("Failed to load level file!")

func _load_level_data(level_data: Dictionary):
	"""Load level data into editor"""
	current_level_name = level_data.get("level_name", "")
	
	# Parse layout string
	var layout = level_data.get("layout", "")
	_string_to_grid(layout)
	_update_grid_manager()

func _grid_to_string() -> String:
	"""Convert grid data to layout string"""
	var result = ""
	for y in range(grid_height):
		for x in range(grid_width):
			var cell_type = grid_data[y][x]
			match cell_type:
				CellType.Type.EMPTY:
					result += "."
				CellType.Type.WALL:
					result += "#"
				CellType.Type.HAZARD:
					result += "X"
				CellType.Type.GOAL:
					result += "G"
				CellType.Type.START:
					result += "S"
		result += "\n"
	return result.trim_suffix("\n")

func _string_to_grid(layout: String):
	"""Convert layout string to grid data"""
	# Parse incoming layout to determine size
	var lines = layout.split("\n")
	var filtered_lines: Array[String] = []
	for line in lines:
		if line.strip_edges() != "":
			filtered_lines.append(line)
	
	if filtered_lines.size() > 0:
		grid_height = min(filtered_lines.size(), MAX_GRID_SIZE)
		grid_width = min(filtered_lines[0].length(), MAX_GRID_SIZE)
	
	_initialize_grid()
	
	for y in range(min(filtered_lines.size(), grid_height)):
		var line = filtered_lines[y]
		for x in range(min(line.length(), grid_width)):
			var char = line[x]
			grid_data[y][x] = CellType.from_char(char)
	
	# Update spinboxes to reflect loaded level size
	width_spinbox.value = grid_width
	height_spinbox.value = grid_height

func _on_test_pressed():
	"""Test the level in game"""
	# Store level data for main scene to load
	var layout_string = _grid_to_string()
	var test_level = {
		"level_id": 999,  # Special ID for test levels
		"level_name": "Test: " + (current_level_name if current_level_name != "" else "Untitled"),
		"layout": layout_string,
		"starter_code": starter_code_input.text,
		"hint_text": hint_input.text
	}
	
	get_tree().root.set_meta("test_level", test_level)
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_menu_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
