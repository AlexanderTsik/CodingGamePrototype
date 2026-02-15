extends Control

@onready var code_input = $HSplitContainer/CodePanel/VBoxContainer/CodeInput
@onready var run_button = $HSplitContainer/CodePanel/VBoxContainer/ButtonContainer/RunButton
@onready var restart_button = $HSplitContainer/CodePanel/VBoxContainer/ButtonContainer/RestartButton
@onready var next_level_button = $HSplitContainer/CodePanel/VBoxContainer/ButtonContainer/NextLevelButton
@onready var output_label = $HSplitContainer/CodePanel/VBoxContainer/OutputLabel
@onready var title_label = $HSplitContainer/CodePanel/VBoxContainer/TitleLabel
@onready var menu_button = $MenuButton
@onready var player = $HSplitContainer/GamePanel/GridBackground/Level/Player
@onready var code_executor = $CodeExecutor

# Debug manager
var debug_manager: DebugManager

# Debug toolbar UI (created programmatically)
var debug_toolbar: PanelContainer
var pause_btn: Button
var resume_btn: Button
var step_over_btn: Button
var step_into_btn: Button
var step_out_btn: Button
var speed_slider: HSlider
var speed_label: Label

# Variable viewer UI (created programmatically)
var variables_panel: PanelContainer
var variables_list: VBoxContainer
var variables_scroll: ScrollContainer
var variables_toggle_btn: Button
var variable_labels: Dictionary = {}

# Call stack UI (created programmatically)
var callstack_panel: PanelContainer
var callstack_list: VBoxContainer
var callstack_scroll: ScrollContainer
var callstack_toggle_btn: Button

# Execution log UI (created programmatically)
var execution_log_panel: PanelContainer
var execution_log: RichTextLabel
var execution_log_scroll: ScrollContainer
var execution_log_toggle_btn: Button
var log_enabled: bool = true
const MAX_LOG_LINES: int = 100
var execution_start_time: int = 0

var grid_manager: GridManager
var is_level_complete: bool = false
var player_is_dead: bool = false
var current_level_id: int = 1
var level_definitions: Node

# Available commands and keywords for code completion
var available_commands = ["moveRight()", "moveLeft()", "moveUp()", "moveDown()", "frontIsClear()", "goalReached()", "onHazard()", "leftIsClear()", "rightIsClear()"]
var available_keywords = ["if", "else", "elif", "for", "while", "do", "function", "return", "in", "range", "and", "or", "not"]

# Example code snippets
var examples = {
	"simple_moves": """# Simple movement
moveRight()
moveRight()
moveUp()
moveLeft()""",
	
	"for_loop": """# For loop example
for (i in range(5)) {
	moveRight()
}""",
	
	"if_else": """# If-else example
x = 5
if (x > 3) {
	moveUp()
	moveUp()
} else {
	moveDown()
}""",
	
	"while_loop": """# While loop example
count = 0
while (count < 3) {
	moveRight()
	count = count + 1
}""",
	
	"sensing": """# Using sensors
while(frontIsClear()) {
	moveRight()
}
moveDown()""",
	
	"function": """# Function example
function square() {
	moveRight()
	moveDown()
	moveLeft()
	moveUp()
}

square()
square()""",
	
	"nested": """# Nested control flow
for (i in range(3)) {
	if (i == 1) {
		moveUp()
	} else {
		moveRight()
	}
}"""
}

func _ready():
	run_button.pressed.connect(_on_run_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	next_level_button.pressed.connect(_on_next_level_button_pressed)
	menu_button.pressed.connect(_on_menu_button_pressed)
	code_executor.execution_complete.connect(_on_execution_complete)
	code_executor.execution_error.connect(_on_execution_error)
	
	# Connect interpreter signals for visual feedback
	# Wait for code_executor to create its interpreter
	await get_tree().process_frame
	var interpreter = code_executor.interpreter
	if interpreter:
		print("DEBUG: Connecting to interpreter signals...")
		interpreter.line_executing.connect(_on_line_executing)
		interpreter.variable_changed.connect(_on_variable_changed)
		interpreter.function_entered.connect(_on_function_entered)
		interpreter.function_exited.connect(_on_function_exited)
		print("DEBUG: Interpreter signals connected!")
		
		# Create and attach debug manager
		debug_manager = DebugManager.new()
		add_child(debug_manager)
		interpreter.set_debug_manager(debug_manager)
		print("DEBUG: Debug manager created and attached!")
	else:
		print("ERROR: Interpreter not found in code_executor!")
	
	# Load level definitions
	level_definitions = load("res://scripts/level_definitions.gd").new()
	
	# Enable code completion
	code_input.code_completion_enabled = true
	code_input.code_completion_prefixes = ["move", "if", "for", "while", "function"]
	code_input.code_completion_requested.connect(_on_code_completion_requested)
	
	# Setup line highlighting
	_setup_execution_highlighting()
	
	# Setup debug toolbar UI
	_setup_debug_toolbar()
	
	# Setup variable viewer UI
	_setup_variable_viewer()
	
	# Setup call stack UI
	_setup_callstack_viewer()
	
	# Setup execution log UI
	_setup_execution_log()
	
	# Set default example code
	code_input.text = examples["simple_moves"]
	
	_update_help_text()
	
	# Load selected level (from level select) or default to level 1
	await get_tree().process_frame
	
	# Check for test level first (from level editor)
	if get_tree().root.has_meta("test_level"):
		var test_level = get_tree().root.get_meta("test_level")
		get_tree().root.remove_meta("test_level")
		_load_custom_level(test_level)
	# Check for custom level
	elif get_tree().root.has_meta("custom_level"):
		var custom_level = get_tree().root.get_meta("custom_level")
		get_tree().root.remove_meta("custom_level")
		_load_custom_level(custom_level)
	# Check for selected level from level select
	elif get_tree().root.has_meta("selected_level"):
		var selected_level = get_tree().root.get_meta("selected_level")
		get_tree().root.remove_meta("selected_level")
		load_level(selected_level)
	else:
		# Default to level 1
		load_level(1)

func load_level(level_id: int):
	"""Load a level by ID"""
	current_level_id = level_id
	var level_def = level_definitions.get_level(level_id)
	
	if level_def.is_empty():
		push_error("Level %d not found!" % level_id)
		return
	
	# Find or create GridManager
	var level_node = get_node("HSplitContainer/GamePanel/GridBackground/Level")
	grid_manager = level_node.get_node_or_null("GridManager")
	
	if not grid_manager:
		grid_manager = GridManager.new()
		grid_manager.name = "GridManager"
		level_node.add_child(grid_manager)
		# Connect signals
		grid_manager.level_completed.connect(_on_level_completed)
		grid_manager.player_died.connect(_on_player_died)
	
	grid_manager.load_level_from_string(level_def["layout"])
	
	# Connect grid manager to player
	if player:
		player.grid_manager = grid_manager
		player.reset_position()
	
	# Explicitly set grid manager reference and refresh grid visual
	var grid_bg = get_node("HSplitContainer/GamePanel/GridBackground")
	if grid_bg:
		grid_bg.grid_manager = grid_manager
		if grid_bg.has_method("refresh"):
			grid_bg.refresh()
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	next_level_button.disabled = true
	
	# Update code editor with starter code
	code_input.text = level_def["starter_code"]
	
	# Update title
	title_label.text = "Level %d: %s" % [level_id, level_def["level_name"]]
	
	# Update output with hint
	output_label.text = level_def["hint_text"]
	
	print("Loaded Level %d: %s" % [level_id, level_def["level_name"]])

func _load_custom_level(level_def: Dictionary):
	"""Load a custom level"""
	current_level_id = level_def.get("level_id", 999)
	
	# Find or create GridManager
	var level_node = get_node("HSplitContainer/GamePanel/GridBackground/Level")
	grid_manager = level_node.get_node_or_null("GridManager")
	
	if not grid_manager:
		grid_manager = GridManager.new()
		grid_manager.name = "GridManager"
		level_node.add_child(grid_manager)
		# Connect signals
		grid_manager.level_completed.connect(_on_level_completed)
		grid_manager.player_died.connect(_on_player_died)
	
	grid_manager.load_level_from_string(level_def["layout"])
	
	# Connect grid manager to player
	if player:
		player.grid_manager = grid_manager
		player.reset_position()
	
	# Explicitly set grid manager reference and refresh grid visual
	var grid_bg = get_node("HSplitContainer/GamePanel/GridBackground")
	if grid_bg:
		grid_bg.grid_manager = grid_manager
		if grid_bg.has_method("refresh"):
			grid_bg.refresh()
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	next_level_button.disabled = true
	
	# Update code editor with starter code
	code_input.text = level_def.get("starter_code", "")
	
	# Update title
	title_label.text = level_def.get("level_name", "Custom Level")
	
	# Update output with hint
	output_label.text = level_def.get("hint_text", "Complete your custom level!")
	
	print("Loaded Custom Level: %s" % level_def.get("level_name", "Untitled"))

func _on_code_completion_requested():
	# Add all available commands as completion options
	for command in available_commands:
		code_input.add_code_completion_option(
			CodeEdit.KIND_FUNCTION,
			command,
			command,
			Color.CYAN
		)
	
	# Add keywords
	for keyword in available_keywords:
		code_input.add_code_completion_option(
			CodeEdit.KIND_MEMBER,
			keyword,
			keyword,
			Color.ORANGE
		)
	
	# Update the completion menu
	code_input.update_code_completion_options(true)

func _on_run_button_pressed():
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	
	# Clear variables, call stack, and log from previous execution
	_clear_variables()
	_clear_callstack()
	_clear_execution_log()
	
	# Start timing for execution log
	execution_start_time = Time.get_ticks_msec()
	
	var code = code_input.text
	output_label.text = "Executing..."
	run_button.disabled = true
	player.reset_position()
	code_executor.execute_code(code, player)

func _on_execution_complete():
	if is_level_complete:
		output_label.text = "🎉 Level Complete! Press 'Next Level' to continue!"
		next_level_button.disabled = false
	elif player_is_dead:
		output_label.text = "💀 You died! Click 'Restart' to try again."
	else:
		output_label.text = "Execution complete! ✓"
	run_button.disabled = false
	
	# Clear line highlighting after execution
	if current_line_highlight >= 0:
		code_input.set_line_background_color(current_line_highlight, Color.TRANSPARENT)
		current_line_highlight = -1

func _on_restart_button_pressed():
	"""Restart current level"""
	load_level(current_level_id)

func _on_next_level_button_pressed():
	"""Load next level"""
	var next_level = current_level_id + 1
	if next_level <= level_definitions.get_level_count():
		load_level(next_level)
	else:
		output_label.text = "🎉 Congratulations! You completed all levels!"
		next_level_button.disabled = true

func _on_menu_button_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_execution_error(error_msg: String):
	output_label.text = "Error: " + error_msg
	run_button.disabled = false

func _on_level_completed():
	"""Called when player reaches goal"""
	is_level_complete = true
	print("🎉 Level completed!")

func _on_player_died():
	"""Called when player hits hazard"""
	player_is_dead = true
	code_executor.stop_execution()
	print("💀 Player died!")

func _update_help_text():
	output_label.text = """Commands:
moveRight(), moveLeft()
moveUp(), moveDown()

Control Flow:
if/elif/else, for, while, do-while

Examples: Press F1-F6
F1: Simple moves
F2: For loop
F3: If-else
F4: While loop
F5: Function
F6: Nested

Click Run to execute!"""

func _input(event):
	# Level selection with number keys 1-8
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_8:
			var level_num = event.keycode - KEY_0
			if level_num <= level_definitions.get_level_count():
				load_level(level_num)
				print("Switched to Level %d" % level_num)
		
		# Example shortcuts (F1-F6)
		match event.keycode:
			KEY_F1:
				code_input.text = examples["simple_moves"]
				_update_help_text()
			KEY_F2:
				code_input.text = examples["for_loop"]
				_update_help_text()
			KEY_F3:
				code_input.text = examples["if_else"]
				_update_help_text()
			KEY_F4:
				code_input.text = examples["while_loop"]
				_update_help_text()
			KEY_F5:
				code_input.text = examples["function"]
				_update_help_text()
			KEY_F6:
				code_input.text = examples["nested"]
				_update_help_text()

# ============================================
# Visual Feedback System
# ============================================

var current_line_highlight: int = -1

func _setup_execution_highlighting():
	"""Setup syntax highlighting for execution feedback"""
	# Enable line numbers (correct property for Godot 4.x)
	code_input.gutters_draw_line_numbers = true
	
	# Add custom gutter for breakpoints
	code_input.add_gutter(0)  # Add gutter at index 0
	code_input.set_gutter_name(0, "breakpoints")
	code_input.set_gutter_draw(0, true)
	code_input.set_gutter_clickable(0, true)
	code_input.set_gutter_width(0, 20)
	code_input.set_gutter_type(0, TextEdit.GUTTER_TYPE_ICON)
	
	# Connect gutter click signal
	code_input.gutter_clicked.connect(_on_gutter_clicked)
	
	print("DEBUG: Execution highlighting and breakpoints enabled!")

func _on_gutter_clicked(line: int, gutter: int):
	"""Handle gutter clicks for breakpoint toggling"""
	if gutter == 0:  # Breakpoint gutter
		if debug_manager:
			debug_manager.toggle_breakpoint(line + 1)  # +1 because lines are 1-indexed in our system
			_update_breakpoint_display(line)
			print("DEBUG: Breakpoint toggled at line %d" % (line + 1))

func _update_breakpoint_display(line: int):
	"""Update the visual display of a breakpoint"""
	var actual_line = line + 1  # Convert to 1-indexed
	if debug_manager and debug_manager.has_breakpoint(actual_line):
		# Set breakpoint icon (red circle)
		if debug_manager.is_breakpoint(actual_line):
			code_input.set_line_gutter_metadata(line, 0, true)
			code_input.set_line_gutter_icon(line, 0, _create_breakpoint_icon(true))
		else:
			# Disabled breakpoint (gray circle)
			code_input.set_line_gutter_metadata(line, 0, false)
			code_input.set_line_gutter_icon(line, 0, _create_breakpoint_icon(false))
	else:
		# Remove breakpoint icon
		code_input.set_line_gutter_icon(line, 0, null)
		code_input.set_line_gutter_metadata(line, 0, null)

func _create_breakpoint_icon(enabled: bool) -> Texture2D:
	"""Create a breakpoint icon texture"""
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Transparent background
	
	# Draw a circle
	var center = Vector2(8, 8)
	var radius = 6
	var color = Color.RED if enabled else Color(0.5, 0.5, 0.5)
	
	# Simple circle drawing
	for x in range(16):
		for y in range(16):
			var dist = Vector2(x, y).distance_to(center)
			if dist <= radius:
				img.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(img)

func _setup_variable_viewer():
	"""Create and setup the variable viewer UI"""
	# Create main panel container
	variables_panel = PanelContainer.new()
	variables_panel.name = "VariablesPanel"
	
	# Create VBoxContainer for layout
	var vbox = VBoxContainer.new()
	variables_panel.add_child(vbox)
	
	# Add title bar with toggle button
	var title_bar = HBoxContainer.new()
	vbox.add_child(title_bar)
	
	var title = Label.new()
	title.text = "Variables"
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title)
	
	variables_toggle_btn = Button.new()
	variables_toggle_btn.text = "Hide"
	variables_toggle_btn.custom_minimum_size = Vector2(60, 0)
	variables_toggle_btn.pressed.connect(_on_variables_toggle)
	title_bar.add_child(variables_toggle_btn)
	
	# Add separator
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	# Create scroll container for variables
	variables_scroll = ScrollContainer.new()
	variables_scroll.name = "VariablesScroll"
	variables_scroll.custom_minimum_size = Vector2(200, 150)
	variables_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(variables_scroll)
	
	# Create VBoxContainer to hold variable labels
	variables_list = VBoxContainer.new()
	variables_list.name = "VariablesList"
	variables_scroll.add_child(variables_list)
	
	# Position the panel below the code editor
	var code_panel = get_node("HSplitContainer/CodePanel/VBoxContainer")
	code_panel.add_child(variables_panel)
	
	# Show panel but hide content initially (so toggle button is visible)
	variables_panel.visible = true
	variables_scroll.visible = false
	
	print("DEBUG: Variable viewer UI created!")

func _setup_callstack_viewer():
	"""Create and setup the call stack viewer UI"""
	# Create main panel container
	callstack_panel = PanelContainer.new()
	callstack_panel.name = "CallStackPanel"
	
	# Create VBoxContainer for layout
	var vbox = VBoxContainer.new()
	callstack_panel.add_child(vbox)
	
	# Add title bar with toggle button
	var title_bar = HBoxContainer.new()
	vbox.add_child(title_bar)
	
	var title = Label.new()
	title.text = "Call Stack"
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title)
	
	callstack_toggle_btn = Button.new()
	callstack_toggle_btn.text = "Hide"
	callstack_toggle_btn.custom_minimum_size = Vector2(60, 0)
	callstack_toggle_btn.pressed.connect(_on_callstack_toggle)
	title_bar.add_child(callstack_toggle_btn)
	
	# Add separator
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	# Create scroll container for call stack
	callstack_scroll = ScrollContainer.new()
	callstack_scroll.name = "CallStackScroll"
	callstack_scroll.custom_minimum_size = Vector2(200, 100)
	callstack_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(callstack_scroll)
	
	# Create VBoxContainer to hold call stack labels
	callstack_list = VBoxContainer.new()
	callstack_list.name = "CallStackList"
	callstack_scroll.add_child(callstack_list)
	
	# Position the panel below the code editor
	var code_panel = get_node("HSplitContainer/CodePanel/VBoxContainer")
	code_panel.add_child(callstack_panel)
	
	# Show panel but hide content initially (so toggle button is visible)
	callstack_panel.visible = true
	callstack_scroll.visible = false
	
	print("DEBUG: Call stack viewer UI created!")

func _setup_execution_log():
	"""Create and setup the execution log UI"""
	# Create main panel container
	execution_log_panel = PanelContainer.new()
	execution_log_panel.name = "ExecutionLogPanel"
	
	# Create VBoxContainer for layout
	var vbox = VBoxContainer.new()
	execution_log_panel.add_child(vbox)
	
	# Add title bar with toggle button
	var title_bar = HBoxContainer.new()
	vbox.add_child(title_bar)
	
	var title = Label.new()
	title.text = "Execution Log"
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title)
	
	execution_log_toggle_btn = Button.new()
	execution_log_toggle_btn.text = "Hide"
	execution_log_toggle_btn.custom_minimum_size = Vector2(60, 0)
	execution_log_toggle_btn.pressed.connect(_on_execution_log_toggle)
	title_bar.add_child(execution_log_toggle_btn)
	
	# Add separator
	var separator = HSeparator.new()
	vbox.add_child(separator)
	
	# Create scroll container for log
	execution_log_scroll = ScrollContainer.new()
	execution_log_scroll.name = "ExecutionLogScroll"
	execution_log_scroll.custom_minimum_size = Vector2(200, 200)
	execution_log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	execution_log_scroll.follow_focus = true
	vbox.add_child(execution_log_scroll)
	
	# Create RichTextLabel for colored log entries
	execution_log = RichTextLabel.new()
	execution_log.name = "ExecutionLogText"
	execution_log.bbcode_enabled = true
	execution_log.scroll_following = true
	execution_log.fit_content = true
	execution_log.custom_minimum_size = Vector2(180, 0)
	execution_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	execution_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	execution_log.add_theme_font_size_override("normal_font_size", 12)
	execution_log_scroll.add_child(execution_log)
	
	# Position the panel below the code editor
	var code_panel = get_node("HSplitContainer/CodePanel/VBoxContainer")
	code_panel.add_child(execution_log_panel)
	
	# Show panel and content by default for testing
	execution_log_panel.visible = true
	execution_log_scroll.visible = true
	execution_log_toggle_btn.text = "Hide"
	
	print("DEBUG: Execution log UI created!")

func _setup_debug_toolbar():
	"""Create debug control toolbar programmatically"""
	# Create main panel
	debug_toolbar = PanelContainer.new()
	debug_toolbar.name = "DebugToolbar"
	var panel_stylebox = StyleBoxFlat.new()
	panel_stylebox.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	panel_stylebox.border_width_left = 2
	panel_stylebox.border_width_right = 2
	panel_stylebox.border_width_top = 2
	panel_stylebox.border_width_bottom = 2
	panel_stylebox.border_color = Color(0.3, 0.6, 0.9, 1.0)
	debug_toolbar.add_theme_stylebox_override("panel", panel_stylebox)
	
	# Create horizontal layout
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	debug_toolbar.add_child(hbox)
	
	# Add label
	var toolbar_label = Label.new()
	toolbar_label.text = "Debug Controls:"
	toolbar_label.add_theme_font_size_override("font_size", 14)
	toolbar_label.add_theme_color_override("font_color", Color.CYAN)
	hbox.add_child(toolbar_label)
	
	# Add separator
	var sep1 = VSeparator.new()
	hbox.add_child(sep1)
	
	# Pause button
	pause_btn = Button.new()
	pause_btn.text = "⏸ Pause"
	pause_btn.custom_minimum_size = Vector2(80, 30)
	pause_btn.pressed.connect(_on_pause_pressed)
	hbox.add_child(pause_btn)
	
	# Resume button
	resume_btn = Button.new()
	resume_btn.text = "▶ Resume"
	resume_btn.custom_minimum_size = Vector2(80, 30)
	resume_btn.disabled = true
	resume_btn.pressed.connect(_on_resume_pressed)
	hbox.add_child(resume_btn)
	
	# Add separator
	var sep2 = VSeparator.new()
	hbox.add_child(sep2)
	
	# Step Over button
	step_over_btn = Button.new()
	step_over_btn.text = "⤵ Step Over"
	step_over_btn.custom_minimum_size = Vector2(100, 30)
	step_over_btn.pressed.connect(_on_step_over_pressed)
	hbox.add_child(step_over_btn)
	
	# Step Into button
	step_into_btn = Button.new()
	step_into_btn.text = "↓ Step Into"
	step_into_btn.custom_minimum_size = Vector2(100, 30)
	step_into_btn.pressed.connect(_on_step_into_pressed)
	hbox.add_child(step_into_btn)
	
	# Step Out button
	step_out_btn = Button.new()
	step_out_btn.text = "↑ Step Out"
	step_out_btn.custom_minimum_size = Vector2(100, 30)
	step_out_btn.pressed.connect(_on_step_out_pressed)
	hbox.add_child(step_out_btn)
	
	# Add separator
	var sep3 = VSeparator.new()
	hbox.add_child(sep3)
	
	# Speed control label
	speed_label = Label.new()
	speed_label.text = "Speed: 1.0x"
	speed_label.add_theme_font_size_override("font_size", 12)
	hbox.add_child(speed_label)
	
	# Speed slider
	speed_slider = HSlider.new()
	speed_slider.min_value = 0.25
	speed_slider.max_value = 5.0
	speed_slider.step = 0.25
	speed_slider.value = 1.0
	speed_slider.custom_minimum_size = Vector2(150, 20)
	speed_slider.value_changed.connect(_on_speed_changed)
	hbox.add_child(speed_slider)
	
	# Speed preset buttons
	var preset_container = HBoxContainer.new()
	preset_container.add_theme_constant_override("separation", 4)
	hbox.add_child(preset_container)
	
	var speed_025_btn = Button.new()
	speed_025_btn.text = "0.25x"
	speed_025_btn.custom_minimum_size = Vector2(50, 20)
	speed_025_btn.pressed.connect(func(): _set_speed_preset(0.25))
	preset_container.add_child(speed_025_btn)
	
	var speed_05_btn = Button.new()
	speed_05_btn.text = "0.5x"
	speed_05_btn.custom_minimum_size = Vector2(50, 20)
	speed_05_btn.pressed.connect(func(): _set_speed_preset(0.5))
	preset_container.add_child(speed_05_btn)
	
	var speed_1_btn = Button.new()
	speed_1_btn.text = "1x"
	speed_1_btn.custom_minimum_size = Vector2(40, 20)
	speed_1_btn.pressed.connect(func(): _set_speed_preset(1.0))
	preset_container.add_child(speed_1_btn)
	
	var speed_2_btn = Button.new()
	speed_2_btn.text = "2x"
	speed_2_btn.custom_minimum_size = Vector2(40, 20)
	speed_2_btn.pressed.connect(func(): _set_speed_preset(2.0))
	preset_container.add_child(speed_2_btn)
	
	var speed_5_btn = Button.new()
	speed_5_btn.text = "5x"
	speed_5_btn.custom_minimum_size = Vector2(40, 20)
	speed_5_btn.pressed.connect(func(): _set_speed_preset(5.0))
	preset_container.add_child(speed_5_btn)
	
	# Add toolbar to main UI (below the button container)
	var code_panel = get_node("HSplitContainer/CodePanel/VBoxContainer")
	var button_container = code_panel.get_node("ButtonContainer")
	var button_idx = button_container.get_index()
	code_panel.add_child(debug_toolbar)
	code_panel.move_child(debug_toolbar, button_idx + 1)
	
	print("DEBUG: Debug toolbar created!")

func _on_line_executing(line_number: int):
	"""Called when a line is about to be executed"""
	print("DEBUG: Highlighting line %d" % line_number)
	
	# Add to execution log
	_add_log_entry("[color=cyan]Line %d[/color]" % line_number)
	
	# Clear previous highlight
	if current_line_highlight >= 0:
		code_input.set_line_background_color(current_line_highlight, Color.TRANSPARENT)
	
	# Highlight current line (line_number is 1-indexed, editor is 0-indexed)
	var editor_line = line_number - 1
	if editor_line >= 0 and editor_line < code_input.get_line_count():
		current_line_highlight = editor_line
		var highlight_color = Color(0.3, 0.5, 1.0, 0.5)  # Increased alpha for visibility
		code_input.set_line_background_color(editor_line, highlight_color)
		print("DEBUG: Applied highlight to line %d with color %s" % [editor_line, highlight_color])
		
		# Scroll to current line
		code_input.set_caret_line(editor_line)
		code_input.center_viewport_to_caret()
	else:
		print("DEBUG: Line %d out of range (total lines: %d)" % [editor_line, code_input.get_line_count()])


func _on_variable_changed(var_name: String, value):
	"""Called when a variable value changes"""
	print("DEBUG: Variable changed: %s = %s" % [var_name, str(value)])
	
	# Add to execution log (always update data)
	_add_log_entry("[color=yellow]%s[/color] = %s" % [var_name, str(value)])
	
	# Update variables panel data (even if hidden)
	if not variables_list:
		return
	
	# Check if label already exists for this variable
	if not variable_labels.has(var_name):
		# Create new label for this variable
		var label = Label.new()
		label.name = "Var_" + var_name
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.add_theme_font_size_override("font_size", 14)
		variables_list.add_child(label)
		variable_labels[var_name] = label
	
	# Update variable display
	var label = variable_labels[var_name]
	var value_str = str(value)
	label.text = "%s = %s" % [var_name, value_str]
	
	# Highlight changed variable briefly
	label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Reset color after a short delay
	await get_tree().create_timer(0.5).timeout
	if label and is_instance_valid(label):
		label.add_theme_color_override("font_color", Color.WHITE)

func _on_function_entered(func_name: String, params: Dictionary):
	"""Called when entering a function"""
	print("DEBUG: Entering function: %s" % func_name)
	
	# Format parameters for log
	var params_str = []
	for key in params:
		params_str.append("%s=%s" % [key, str(params[key])])
	var params_display = ", ".join(params_str) if params_str.size() > 0 else ""
	
	# Add to execution log (always update data)
	_add_log_entry("[color=green]→ Entering[/color] %s(%s)" % [func_name, params_display])
	
	# Update call stack (even if hidden)
	if not callstack_list:
		return
	
	# Create label for this function call
	var label = Label.new()
	label.name = "Call_" + str(callstack_list.get_child_count())
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.add_theme_font_size_override("font_size", 14)
	label.text = "→ %s(%s)" % [func_name, params_display]
	
	# Add indent based on depth
	var depth = callstack_list.get_child_count()
	label.text = "  ".repeat(depth) + label.text
	
	# Highlight in green to indicate entry
	label.add_theme_color_override("font_color", Color.GREEN)
	
	callstack_list.add_child(label)

func _on_function_exited(func_name: String, return_value):
	"""Called when exiting a function"""
	print("DEBUG: Exiting function: %s (returned: %s)" % [func_name, str(return_value)])
	
	# Add to execution log
	_add_log_entry("[color=red]← Exiting[/color] %s (returned: %s)" % [func_name, str(return_value)])
	
	if not callstack_list or callstack_list.get_child_count() == 0:
		return
	
	# Get the last (most recent) call in the stack
	var last_child = callstack_list.get_child(callstack_list.get_child_count() - 1)
	
	if last_child:
		# Briefly highlight in red to show exit
		last_child.add_theme_color_override("font_color", Color.RED)
		await get_tree().create_timer(0.3).timeout
		
		# Remove the call from the stack
		if last_child and is_instance_valid(last_child):
			last_child.queue_free()
	
	# Hide panel if stack is empty
	if callstack_list.get_child_count() == 0 and callstack_panel:
		callstack_panel.visible = false


func _clear_variables():
	"""Clear all variable labels from the viewer"""
	if not variables_list:
		return
	
	# Remove all child labels
	for child in variables_list.get_children():
		child.queue_free()
	
	# Clear the dictionary
	variable_labels.clear()
	
	print("DEBUG: Variables cleared")

func _clear_callstack():
	"""Clear all call stack labels from the viewer"""
	if not callstack_list:
		return
	
	# Remove all child labels
	for child in callstack_list.get_children():
		child.queue_free()
	
	print("DEBUG: Call stack cleared")

func _add_log_entry(text: String):
	"""Add an entry to the execution log with timestamp"""
	if not execution_log:
		print("ERROR: execution_log is null!")
		return
	
	# Calculate elapsed time
	var elapsed_ms = Time.get_ticks_msec() - execution_start_time
	var elapsed_sec = elapsed_ms / 1000.0
	
	# Build entry using RichTextLabel methods for proper formatting
	# Add timestamp in gray
	execution_log.push_color(Color.GRAY)
	execution_log.add_text("[%.2fs] " % elapsed_sec)
	execution_log.pop()
	
	# Add the text (with BBCode already in it)
	execution_log.append_text(text + "\n")
	
	print("DEBUG: Added log entry at %.2fs" % elapsed_sec)
	
	# Limit log size by line count
	var line_count = execution_log.get_line_count()
	if line_count > MAX_LOG_LINES:
		# Get all text and remove oldest lines
		var all_lines = execution_log.text.split("\n")
		var keep_lines = all_lines.slice(all_lines.size() - MAX_LOG_LINES, all_lines.size())
		execution_log.clear()
		for line in keep_lines:
			execution_log.append_text(line + "\n")


func _clear_execution_log():
	"""Clear the execution log"""
	if not execution_log:
		return
	
	execution_log.clear()
	
	print("DEBUG: Execution log cleared")

# ============================================
# Toggle Functions for Panels
# ============================================

func _on_variables_toggle():
	"""Toggle variables panel visibility"""
	if not variables_scroll or not variables_toggle_btn:
		return
	
	if variables_scroll.visible:
		variables_scroll.visible = false
		variables_toggle_btn.text = "Show"
	else:
		variables_scroll.visible = true
		variables_toggle_btn.text = "Hide"

func _on_callstack_toggle():
	"""Toggle call stack panel visibility"""
	if not callstack_scroll or not callstack_toggle_btn:
		return
	
	if callstack_scroll.visible:
		callstack_scroll.visible = false
		callstack_toggle_btn.text = "Show"
	else:
		callstack_scroll.visible = true
		callstack_toggle_btn.text = "Hide"

func _on_execution_log_toggle():
	"""Toggle execution log panel visibility"""
	if not execution_log_scroll or not execution_log_toggle_btn:
		return
	
	if execution_log_scroll.visible:
		execution_log_scroll.visible = false
		execution_log_toggle_btn.text = "Show"
	else:
		execution_log_scroll.visible = true
		execution_log_toggle_btn.text = "Hide"

func _print_node_tree(node: Node, depth: int):
	"""Debug helper to print node hierarchy"""
	print("  ".repeat(depth) + node.name + " (" + node.get_class() + ")")
	for child in node.get_children():
		_print_node_tree(child, depth + 1)

# ============================================
# Debug Control Functions
# ============================================

func _on_pause_pressed():
	"""Handle pause button press"""
	if debug_manager:
		debug_manager.pause()
		pause_btn.disabled = true
		resume_btn.disabled = false
		print("DEBUG: Pause button pressed")

func _on_resume_pressed():
	"""Handle resume button press"""
	if debug_manager:
		debug_manager.resume()
		pause_btn.disabled = false
		resume_btn.disabled = true
		print("DEBUG: Resume button pressed")

func _on_step_over_pressed():
	"""Handle step over button press"""
	if debug_manager:
		debug_manager.step_over()
		pause_btn.disabled = true
		resume_btn.disabled = false
		print("DEBUG: Step over button pressed")

func _on_step_into_pressed():
	"""Handle step into button press"""
	if debug_manager:
		debug_manager.step_into()
		pause_btn.disabled = true
		resume_btn.disabled = false
		print("DEBUG: Step into button pressed")

func _on_step_out_pressed():
	"""Handle step out button press"""
	if debug_manager:
		debug_manager.step_out()
		pause_btn.disabled = true
		resume_btn.disabled = false
		print("DEBUG: Step out button pressed")

func _on_speed_changed(value: float):
	"""Handle speed slider change"""
	var interpreter = code_executor.interpreter
	if interpreter:
		interpreter.set_execution_speed(value)
		speed_label.text = "Speed: %.2fx" % value
		print("DEBUG: Speed changed to %.2fx" % value)

func _set_speed_preset(speed: float):
	"""Set speed to a preset value"""
	speed_slider.value = speed
	# _on_speed_changed will be called automatically
