extends Control

# Note: GridManager, DebugManager, WatchManager, CellType are auto-loaded via class_name

@onready var code_input = $HSplitContainer/CodePanel/VSplitContainer/TopSection/CodeInput
@onready var run_button = $HSplitContainer/CodePanel/VSplitContainer/TopSection/ButtonContainer/RunButton
@onready var stop_button = $HSplitContainer/CodePanel/VSplitContainer/TopSection/ButtonContainer/StopButton
@onready var restart_button = $HSplitContainer/CodePanel/VSplitContainer/TopSection/ButtonContainer/RestartButton
@onready var next_level_button = $HSplitContainer/CodePanel/VSplitContainer/TopSection/ButtonContainer/NextLevelButton
@onready var menu_button = $HSplitContainer/CodePanel/VSplitContainer/TopSection/ButtonContainer/MenuButton
@onready var output_label = $HSplitContainer/CodePanel/VSplitContainer/TopSection/OutputPanel/OutputScroll/OutputMargin/OutputLabel
@onready var title_label = $HSplitContainer/CodePanel/VSplitContainer/TopSection/TitleBar/TitleLabel
@onready var player = $HSplitContainer/GamePanel/GridBackground/Level/Player
@onready var code_executor = $CodeExecutor
@onready var hsplit_container = $HSplitContainer
@onready var vsplit_container = $HSplitContainer/CodePanel/VSplitContainer

# Debug manager
var debug_manager

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

# Execution log UI (created programmatically)
var execution_log_panel: PanelContainer
var execution_log: RichTextLabel
var execution_log_scroll: ScrollContainer
var execution_log_toggle_btn: Button
var log_enabled: bool = true
const MAX_LOG_LINES: int = 100
var execution_start_time: int = 0

# Help popup UI (created programmatically)
var help_popup: PopupPanel
var help_button: Button

# Debug mode control
var debug_mode: bool = false
var debug_button: Button

# Theme control
var is_dark_mode: bool = true
var theme_toggle_button: Button

# Syntax highlighter
var syntax_highlighter: CodeHighlighter

# Editor zoom & completion toggle
var editor_font_size     : int   = 16
const FONT_SIZE_MIN      : int   = 10
const FONT_SIZE_MAX      : int   = 36
var _zoom_label          : Label
var _hints_btn           : Button
var _completion_on       : bool  = true

# Execution speed (shared by normal run and debug mode)
var _exec_speed          : float = 1.0
var _speed_label_toolbar : Label
var _split_locked: bool = false
var _locked_hsplit_offset: int = 0
var _locked_vsplit_offset: int = 0

var grid_manager: GridManager
var is_level_complete: bool = false
var player_is_dead: bool = false
var current_level_id: int = 1
# Tracks where the current level came from so restart / next-level /
# leaderboard can dispatch correctly:
#   "builtin"   — bundled tutorial levels  (use current_level_id)
#   "local"     — user-saved JSON file     (use cached dict, no leaderboard)
#   "community" — fetched from Supabase    (use UUID, has leaderboard)
var current_level_source: String = "builtin"
# Cached level dict — needed so we can restart custom levels (which aren't
# in level_definitions) without re-fetching from disk or the network.
var current_level_dict: Dictionary = {}
var current_level_variants: Array[String] = []
var level_definitions: Node

# Variant preview bar (numbered buttons at the bottom of the game panel)
var _variant_bar_panel: PanelContainer = null
var _variant_btn_row: HBoxContainer = null
var _variant_buttons: Array[Button] = []

# Set when a variant goal was reached mid-run; causes _on_execution_complete
# to re-execute the code from scratch on the new variant instead of finishing.
var _rerun_after_variant: bool = false

# One-time intro popup shown the first time a variant level is loaded.
var _variant_intro_popup: AcceptDialog = null
var _shown_variant_intro: bool = false

# Interactive guided tutorial (offered once, the first time a level loads).
var _tutorial_overlay: TutorialOverlay = null
var _offered_tutorial: bool = false

# First-encounter hazard/lava explanations (each shown at most once per session).
var _explained_hazard: bool = false
var _explained_lava: bool = false

# Win / leaderboard popup (built + managed by win_popup.gd)
var _win_popup: WinPopup

# Available commands and keywords for code completion
var available_commands = ["move()", "turnRight()", "turnLeft()", "turnBack()", "frontIsClear()", "goalReached()", "onHazard()", "hasKey()", "leftIsClear()", "rightIsClear()"]
var available_keywords = ["if", "else", "elif", "for", "while", "do", "function", "return", "in", "range", "and", "or", "not"]

# Example code snippets
var examples = {
	"simple_moves": """# Simple movement with turns
move()
move()
turnRight()
move()
turnLeft()
move()""",
	
	"for_loop": """# For loop example
for (i in range(5)) {
	move()
}
turnRight()
move()""",
	
	"if_else": """# If-else example
x = 5
if (x > 3) {
	move()
	move()
} else {
	turnBack()
	move()
}""",
	
	"while_loop": """# While loop with sensors
while (frontIsClear()) {
	move()
}
turnRight()""",
	
	"sensing": """# Using sensors
while(frontIsClear()) {
	move()
}
turnRight()
while(frontIsClear()) {
	move()
}""",
	
	"function": """# Function example
function square() {
	for (i in range(4)) {
		move()
		turnRight()
	}
}

square()
move()
square()""",
	
	"nested": """# Nested control flow
for (i in range(3)) {
	if (i == 1) {
		turnLeft()
		move()
	} else {
		move()
	}
}"""
}

func _ready():
	set_process(true)
	run_button.pressed.connect(_on_run_button_pressed)
	stop_button.pressed.connect(_on_stop_button_pressed)
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
		Dbg.p("DEBUG: Connecting to interpreter signals...")
		interpreter.line_executing.connect(_on_line_executing)
		interpreter.variable_changed.connect(_on_variable_changed)
		interpreter.function_entered.connect(_on_function_entered)
		interpreter.function_exited.connect(_on_function_exited)
		Dbg.p("DEBUG: Interpreter signals connected!")
		
		# Create and attach debug manager
		debug_manager = DebugManager.new()
		add_child(debug_manager)
		interpreter.set_debug_manager(debug_manager)
		Dbg.p("DEBUG: Debug manager created and attached!")
	else:
		Dbg.p("ERROR: Interpreter not found in code_executor!")
	
	# Load level definitions
	level_definitions = load("res://scripts/levels/level_definitions.gd").new()
	
	# Setup syntax highlighting
	_setup_syntax_highlighting()
	
	# Enable code completion
	code_input.code_completion_enabled = true
	# Two-char prefixes avoid the popup firing on every keypress while still
	# triggering early enough to feel responsive.
	code_input.code_completion_prefixes = [
		"mo", "tu", "fr", "le", "ri", "go", "on",             # function starts
		"if", "el", "fo", "wh", "fu", "re", "in", "ra",       # keyword starts
	]
	code_input.code_completion_requested.connect(_on_code_completion_requested)
	# Ctrl+scroll zoom on the code editor
	code_input.gui_input.connect(_on_code_input_gui_input)
	
	# Setup line highlighting
	_setup_execution_highlighting()
	
	# Setup debug toolbar UI
	_setup_debug_toolbar()
	
	# Setup variable viewer UI
	_setup_variable_viewer()
	
	# Setup execution log UI
	_setup_execution_log()
	
	# Setup help button and popup
	_setup_help_system()

	# Setup variant preview bar and first-time intro popup
	_setup_variant_bar()
	_setup_variant_intro_popup()

	# Setup zoom + hints toolbar (sits between button bar and code editor)
	_setup_editor_toolbar()

	# Setup win / leaderboard popup
	_win_popup = WinPopup.new(self)
	add_child(_win_popup)

	# Setup interactive guided tutorial overlay
	_tutorial_overlay = TutorialOverlay.new(self)
	add_child(_tutorial_overlay)

	# Set default example code
	code_input.text = examples["simple_moves"]

	_update_help_text()

	# Apply theme so all programmatically-added buttons get the right look
	_apply_theme()
	
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

func _process(_delta: float) -> void:
	if _split_locked:
		_enforce_split_lock()

func load_level(level_id: int):
	"""Load a level by ID"""
	current_level_id = level_id
	current_level_source = "builtin"
	current_level_dict = {}
	current_level_variants.clear()
	# Built-in levels do have a "Next Level" — re-enable the button
	# (it's hidden for custom levels via _load_custom_level).
	next_level_button.visible = true
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
		grid_manager.variant_advanced.connect(_on_variant_advanced)
		grid_manager.grid_changed.connect(_on_grid_changed)

	if level_id > 5 and level_def.has("variants") and level_def["variants"] is Array and level_def["variants"].size() > 0:
		for layout in level_def["variants"]:
			current_level_variants.append(str(layout))
		grid_manager.set_active_variants(current_level_variants)
		_apply_current_variant_layout()
	else:
		grid_manager.clear_active_variants()
		grid_manager.load_level_from_string(level_def["layout"])
		_reset_player_and_refresh_grid()
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	next_level_button.disabled = true
	
	# Update code editor with starter code (or solution if DEV_MODE is on)
	code_input.text = level_definitions.get_starter_or_solution(level_id)
	
	# Update title
	_update_title_with_variant(level_def["level_name"])
	
	# Update output with hint
	if current_level_variants.size() > 0:
		output_label.text = "%s\n\nVariant 1/%d — click the numbered buttons below the grid to preview each variation." % [level_def["hint_text"], current_level_variants.size()]
	else:
		output_label.text = level_def["hint_text"]

	# Build / hide the variant preview strip and trigger intro popup.
	_update_variant_bar()
	if current_level_variants.size() > 0:
		_show_variant_intro_if_needed()

	# Offer the interactive tutorial the first time a level loads.
	_offer_tutorial_if_needed()

	# Explain hazards / lava the first time they appear on the grid.
	_explain_hazards_if_needed()

	Dbg.p("Loaded Level %d: %s" % [level_id, level_def["level_name"]])

func _load_custom_level(level_def: Dictionary):
	"""Load a custom level (community-fetched, locally-saved, or under-test)."""
	# Cache the full dict so Restart can reload without a re-fetch / re-read.
	current_level_dict = level_def
	current_level_source = level_def.get("level_source", "local")
	current_level_variants.clear()
	# current_level_id stays as a sentinel for non-builtin levels — never used
	# for lookup in level_definitions. The real ID lives in level_def["level_id"]
	# (UUID for community, absent for local).
	current_level_id = 999
	# Custom levels have no "Next Level" — hide the button. A "Back to Levels"
	# affordance lives in _on_next_level_button_pressed for non-builtin sources.
	next_level_button.visible = false

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
		grid_manager.variant_advanced.connect(_on_variant_advanced)
		grid_manager.grid_changed.connect(_on_grid_changed)

	grid_manager.clear_active_variants()
	grid_manager.load_level_from_string(level_def["layout"])
	_reset_player_and_refresh_grid()
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	next_level_button.disabled = true
	
	# Update code editor with starter code
	code_input.text = level_def.get("starter_code", "")

	# Update title — show "by <author>" for community levels.
	var lvl_name : String = level_def.get("level_name", "Custom Level")
	var author   : String = level_def.get("author", "")
	if current_level_source == "community" and author != "":
		title_label.text = "%s — by %s" % [lvl_name, author]
	else:
		title_label.text = lvl_name

	# Update output with hint
	output_label.text = level_def.get("hint_text", "Complete your custom level!")

	# Custom levels never have variants — hide the preview bar.
	_update_variant_bar()

	# Offer the interactive tutorial the first time a level loads.
	_offer_tutorial_if_needed()

	# Explain hazards / lava the first time they appear on the grid.
	_explain_hazards_if_needed()

	Dbg.p("Loaded Custom Level: %s (source: %s)" % [lvl_name, current_level_source])

func _on_grid_changed() -> void:
	"""The grid mutated at runtime (a key was picked up or a door opened).
	Redraw the grid background so the change is visible."""
	var grid_bg = get_node_or_null("HSplitContainer/GamePanel/GridBackground")
	if grid_bg and grid_bg.has_method("refresh"):
		grid_bg.refresh()

func _reset_player_and_refresh_grid(preserve_move_count: bool = false) -> void:
	var previous_moves := 0
	if preserve_move_count and player:
		previous_moves = player.move_count

	# Refresh grid visual FIRST so tile_size is recalculated for the new
	# grid dimensions before the player calculates its world position.
	var grid_bg = get_node("HSplitContainer/GamePanel/GridBackground")
	if grid_bg:
		grid_bg.grid_manager = grid_manager
		if grid_bg.has_method("refresh"):
			grid_bg.refresh()

	if player:
		player.grid_manager = grid_manager
		player.reset_position()
		if preserve_move_count:
			player.move_count = previous_moves

func _apply_current_variant_layout(preserve_move_count: bool = false) -> void:
	"""Load the current variant layout into the grid and reset player/visuals.
	Used for initial load and new-run resets. During mid-run transitions the
	grid is already loaded by GridManager itself — see _on_variant_advanced."""
	if not grid_manager:
		return
	var layout := grid_manager.get_current_variant_layout()
	if layout == "":
		return
	grid_manager.load_level_from_string(layout)
	_reset_player_and_refresh_grid(preserve_move_count)

func _update_title_with_variant(level_name: String) -> void:
	if current_level_source == "builtin" and grid_manager and grid_manager.has_active_variants():
		title_label.text = "Level %d: %s (Variant %d/%d)" % [
			current_level_id,
			level_name,
			grid_manager.get_current_variant_number(),
			grid_manager.get_total_variants()
		]
		return
	title_label.text = "Level %d: %s" % [current_level_id, level_name]

func _on_variant_advanced(current_variant: int, total_variants: int) -> void:
	# GridManager already loaded the new variant's grid.
	# Stop the current interpreter run — _on_execution_complete will detect
	# _rerun_after_variant and re-execute the full code from scratch on the new grid.
	_rerun_after_variant = true
	code_executor.stop_execution()
	var level_def = level_definitions.get_level(current_level_id)
	_update_title_with_variant(level_def.get("level_name", "Level"))
	output_label.text = "Variant %d/%d solved! Re-running your code for variant %d/%d..." % [
		current_variant - 1,
		total_variants,
		current_variant,
		total_variants
	]
	output_label.add_theme_color_override("font_color", Color(0.40, 0.90, 0.55, 1))
	_highlight_variant_button(current_variant - 1)
	Dbg.p("Variant %d/%d solved, will re-run code from scratch" % [current_variant - 1, total_variants])

func _reset_variant_state_for_new_run() -> void:
	if current_level_source != "builtin" or current_level_variants.size() == 0 or not grid_manager:
		return
	_rerun_after_variant = false
	grid_manager.set_active_variants(current_level_variants)
	_apply_current_variant_layout()
	_highlight_variant_button(0)
	_set_variant_bar_interactive(false)
	var level_def = level_definitions.get_level(current_level_id)
	_update_title_with_variant(level_def.get("level_name", "Level"))

# ─────────────────────────────────────────────────────────────────────────────
# Variant preview bar
# ─────────────────────────────────────────────────────────────────────────────

func _setup_variant_bar() -> void:
	"""Create the variant preview strip anchored to the bottom of the game panel."""
	var grid_bg = get_node("HSplitContainer/GamePanel/GridBackground")

	_variant_bar_panel = PanelContainer.new()
	_variant_bar_panel.name = "VariantBar"

	# Anchor to the bottom edge of GridBackground (fills its full width).
	_variant_bar_panel.anchor_left   = 0.0
	_variant_bar_panel.anchor_right  = 1.0
	_variant_bar_panel.anchor_top    = 1.0
	_variant_bar_panel.anchor_bottom = 1.0
	_variant_bar_panel.offset_top    = -48.0
	_variant_bar_panel.offset_bottom = 0.0
	_variant_bar_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.08, 0.13, 0.92)
	style.border_width_top = 1
	style.border_color = Color(0.28, 0.32, 0.52, 1.0)
	_variant_bar_panel.add_theme_stylebox_override("panel", style)

	_variant_btn_row = HBoxContainer.new()
	_variant_btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_variant_btn_row.add_theme_constant_override("separation", 6)
	_variant_bar_panel.add_child(_variant_btn_row)

	var lbl = Label.new()
	lbl.text = "Preview variant:"
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.60, 0.65, 0.85, 1.0))
	_variant_btn_row.add_child(lbl)

	grid_bg.add_child(_variant_bar_panel)
	_variant_bar_panel.visible = false

func _update_variant_bar() -> void:
	"""Rebuild variant buttons to match current_level_variants."""
	if not _variant_bar_panel or not _variant_btn_row:
		return

	# Remove old numbered buttons (keep the label, which is child 0).
	for btn in _variant_buttons:
		_variant_btn_row.remove_child(btn)
		btn.queue_free()
	_variant_buttons.clear()

	var count = current_level_variants.size()
	if count == 0:
		_variant_bar_panel.visible = false
		return

	for i in range(count):
		var btn = Button.new()
		btn.text = str(i + 1)
		btn.tooltip_text = "Preview Variant %d" % (i + 1)
		btn.custom_minimum_size = Vector2(36, 28)
		var idx = i  # capture for lambda
		btn.pressed.connect(func(): _on_variant_preview_pressed(idx))
		_variant_btn_row.add_child(btn)
		_variant_buttons.append(btn)

	_variant_bar_panel.visible = true
	_highlight_variant_button(0)

func _highlight_variant_button(idx: int) -> void:
	"""Visually mark button `idx` as the active variant."""
	var active_style = StyleBoxFlat.new()
	active_style.bg_color = Color(0.18, 0.45, 0.82, 1.0)
	active_style.border_width_left   = 2
	active_style.border_width_right  = 2
	active_style.border_width_top    = 2
	active_style.border_width_bottom = 2
	active_style.border_color = Color(0.40, 0.70, 1.0, 1.0)
	active_style.corner_radius_top_left     = 4
	active_style.corner_radius_top_right    = 4
	active_style.corner_radius_bottom_left  = 4
	active_style.corner_radius_bottom_right = 4

	for i in range(_variant_buttons.size()):
		var btn = _variant_buttons[i]
		if i == idx:
			btn.add_theme_stylebox_override("normal",  active_style)
			btn.add_theme_stylebox_override("hover",   active_style)
			btn.add_theme_stylebox_override("pressed", active_style)
		else:
			btn.remove_theme_stylebox_override("normal")
			btn.remove_theme_stylebox_override("hover")
			btn.remove_theme_stylebox_override("pressed")

func _set_variant_bar_interactive(enabled: bool) -> void:
	"""Enable or disable variant preview buttons (disabled during execution)."""
	for btn in _variant_buttons:
		btn.disabled = not enabled

func _on_variant_preview_pressed(idx: int) -> void:
	"""Preview variant `idx` grid without running code."""
	if idx < 0 or idx >= current_level_variants.size() or not grid_manager:
		return
	# Load the selected variant for display only; the actual run always resets
	# to variant 1 when the Run button is pressed.
	grid_manager.load_level_from_string(current_level_variants[idx])
	_reset_player_and_refresh_grid(false)
	_highlight_variant_button(idx)
	var level_def = level_definitions.get_level(current_level_id)
	title_label.text = "Level %d: %s (Variant %d/%d — preview)" % [
		current_level_id,
		level_def.get("level_name", "Level"),
		idx + 1,
		current_level_variants.size()
	]

# ─────────────────────────────────────────────────────────────────────────────
# Variant intro popup
# ─────────────────────────────────────────────────────────────────────────────

func _setup_variant_intro_popup() -> void:
	"""Create the one-time intro popup for multi-variant levels."""
	_variant_intro_popup = AcceptDialog.new()
	_variant_intro_popup.exclusive = false
	_variant_intro_popup.title = "Multi-Variant Levels"
	_variant_intro_popup.dialog_text = \
"""Starting from Level 6, every level has multiple variations of the same puzzle.

Your code must solve ALL variations using a single program.
LediBug will re-run your code from the beginning on each variation — it must reach the goal every time.

To preview the variations before running:
  • Use the numbered buttons at the bottom of the game panel.
  • Click each number to see what that variation looks like.
  • Click Run when you're ready to test your solution.

Good luck!"""
	_variant_intro_popup.size = Vector2(500, 300)
	add_child(_variant_intro_popup)

func _show_variant_intro_if_needed() -> void:
	"""Show the variant intro popup the first time a variant level is loaded."""
	if _shown_variant_intro or not _variant_intro_popup:
		return
	_shown_variant_intro = true
	# Wait one frame so the level finishes loading before the popup appears.
	await get_tree().process_frame
	_variant_intro_popup.popup_centered()

# ─────────────────────────────────────────────────────────────────────────────
# Interactive guided tutorial
# ─────────────────────────────────────────────────────────────────────────────

func _offer_tutorial_if_needed() -> void:
	"""The first time a level loads, ask the player if they want a guided tour.
	On "Yes", the overlay walks through each control one step at a time."""
	if _offered_tutorial or not _tutorial_overlay:
		return
	_offered_tutorial = true
	# Wait one frame so the layout is settled before measuring control rects.
	await get_tree().process_frame
	# A first-time "Multi-Variant Levels" dialog may pop on this same level load.
	# Two exclusive child windows can't be on screen at once (Godot logs an
	# error and refuses the second), so wait for that dialog to close first.
	while is_instance_valid(_variant_intro_popup) and _variant_intro_popup.visible:
		await _variant_intro_popup.visibility_changed
	_tutorial_overlay.begin(_build_tutorial_steps())

func _build_tutorial_steps() -> Array:
	"""Define the ordered tour: each step spotlights one control with a tip."""
	var output_panel = get_node_or_null(
		"HSplitContainer/CodePanel/VSplitContainer/TopSection/OutputPanel")
	var game_panel = get_node_or_null("HSplitContainer/GamePanel")

	var steps: Array = [
		{
			"node": code_input,
			"title": "Write Your Code",
			"text": "This is the code editor. Type commands here like move() and turnRight() to guide LediBug.",
		},
		{
			"node": run_button,
			"title": "Run",
			"text": "When your code is ready, click Run to execute it and watch LediBug follow your instructions.",
		},
		{
			"node": debug_button,
			"title": "Debug",
			"text": "Click Debug to run your code step by step. You can pause, step through each line, and inspect your variables to find out exactly what your program is doing.",
		},
		{
			"node": stop_button,
			"title": "Stop",
			"text": "Click Stop to halt a running program at any moment.",
		},
		{
			"node": restart_button,
			"title": "Restart",
			"text": "Restart resets the level back to the beginning so you can try a new approach.",
		},
		{
			"node": help_button,
			"title": "Help",
			"text": "Stuck on the syntax? Click Help to open the full command reference — every command, keyword, and example in one place.",
		},
		{
			"node": output_panel,
			"title": "Output",
			"text": "Messages, results, and any errors from your code appear here.",
		},
		{
			"node": game_panel,
			"title": "The Puzzle",
			"text": "This is the grid. Guide LediBug to the goal while avoiding hazards.",
		},
		{
			"node": menu_button,
			"title": "Menu",
			"text": "Use Menu to return to the main menu whenever you like. That's it — have fun!",
		},
	]

	# Drop any steps whose target control isn't present in this scene.
	var valid: Array = []
	for step in steps:
		if step["node"] != null and is_instance_valid(step["node"]):
			valid.append(step)
	return valid

func _explain_hazards_if_needed() -> void:
	"""The first time a HAZARD or LAVA cell appears on the grid, spotlight it
	and explain what it is (with an arrow). Each kind is explained at most once
	per session, and never while the guided tour is on screen."""
	if _tutorial_overlay == null or _tutorial_overlay.is_active():
		return
	if _explained_hazard and _explained_lava:
		return
	if grid_manager == null or grid_manager.grid.is_empty():
		return

	# Find the first hazard cell and the first lava cell, if any.
	var hazard_cell := Vector2i(-1, -1)
	var lava_cell := Vector2i(-1, -1)
	for y in range(grid_manager.grid_height):
		for x in range(grid_manager.grid_width):
			var ct: int = grid_manager.grid[y][x]
			if ct == CellType.Type.LAVA and lava_cell.x < 0:
				lava_cell = Vector2i(x, y)

	# Show only ONE explanation per level load (hazard takes priority).
	var cell := Vector2i(-1, -1)
	var title := ""
	var text := ""
	var accent := Color.WHITE
	var is_hazard_kind := false
	if hazard_cell.x >= 0 and not _explained_hazard:
		cell = hazard_cell
		is_hazard_kind = true
		title = "Watch out — Hazard!"
		text = "The glowing red cell is a HAZARD. If LediBug steps on it, the run ends instantly! Luckily your sensors — frontIsClear(), rightIsClear() and so on — treat hazards exactly like walls, so a wall-follower walks safely around them."
		accent = Color(0.95, 0.30, 0.34)
	elif lava_cell.x >= 0 and not _explained_lava:
		cell = lava_cell
		title = "Watch out — Lava!"
		text = "The glowing orange cell is LAVA. Touching it is instant game over! Good news: your sensors see lava just like a wall, so following the open path keeps LediBug safe."
		accent = Color(0.98, 0.52, 0.18)
	else:
		return

	# Wait a frame so the grid has laid out and tile_size is current.
	await get_tree().process_frame
	# The tour may have appeared meanwhile — never overlap it.
	if _tutorial_overlay.is_active():
		return
	# Mark explained only now that we are actually showing it.
	if is_hazard_kind:
		_explained_hazard = true
	else:
		_explained_lava = true
	var getter := Callable(self, "_grid_cell_screen_rect").bind(cell)
	_tutorial_overlay.explain(title, text, getter, accent)

func _grid_cell_screen_rect(cell: Vector2i) -> Rect2:
	"""Screen-space rect of one grid cell, used to anchor the spotlight/arrow."""
	var grid_bg = get_node_or_null("HSplitContainer/GamePanel/GridBackground")
	if grid_bg == null or grid_manager == null:
		return Rect2()
	var cs := float(grid_manager.tile_size)
	var origin := (grid_bg as Control).get_global_rect().position
	var off = grid_bg.get("grid_offset")
	if off is Vector2:
		origin += off
	return Rect2(origin + Vector2(cell.x * cs, cell.y * cs), Vector2(cs, cs))

func _on_code_completion_requested():
	"""Provide categorized code completion options.

	IMPORTANT: display_text must start with exactly the text the user is typing so
	Godot's internal prefix filter can match it correctly. Do NOT prepend category
	labels or descriptions — put them in insert_text comments instead (they are
	never shown in the popup display_text column).
	"""
	var sky   := Color(0.33, 0.80, 0.98, 1.0)  # sky blue   — movement
	var leaf  := Color(0.42, 0.90, 0.52, 1.0)  # leaf green — sensors
	var mauve := Color(0.82, 0.38, 0.72, 1.0)  # mauve      — keywords

	# ── Movement ─────────────────────────────────────────────────────────
	_add_completion(CodeEdit.KIND_FUNCTION, "move()",      "move()",      sky)
	_add_completion(CodeEdit.KIND_FUNCTION, "turnRight()", "turnRight()", sky)
	_add_completion(CodeEdit.KIND_FUNCTION, "turnLeft()",  "turnLeft()",  sky)
	_add_completion(CodeEdit.KIND_FUNCTION, "turnBack()",  "turnBack()",  sky)

	# ── Sensors ──────────────────────────────────────────────────────────
	_add_completion(CodeEdit.KIND_FUNCTION, "frontIsClear()", "frontIsClear()", leaf)
	_add_completion(CodeEdit.KIND_FUNCTION, "leftIsClear()",  "leftIsClear()",  leaf)
	_add_completion(CodeEdit.KIND_FUNCTION, "rightIsClear()", "rightIsClear()", leaf)
	_add_completion(CodeEdit.KIND_FUNCTION, "goalReached()",  "goalReached()",  leaf)
	_add_completion(CodeEdit.KIND_FUNCTION, "onHazard()",     "onHazard()",     leaf)
	_add_completion(CodeEdit.KIND_FUNCTION, "hasKey()",       "hasKey()",       leaf)

	# ── Keywords ─────────────────────────────────────────────────────────
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "if",       "if ",       mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "else",     "else",      mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "elif",     "elif ",     mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "for",      "for ",      mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "while",    "while ",    mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "function", "function ", mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "return",   "return",    mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "in",       "in ",       mauve)
	_add_completion(CodeEdit.KIND_PLAIN_TEXT, "range",    "range()",   mauve)

	code_input.update_code_completion_options(true)

func _add_completion(kind: int, display: String, insert: String, color: Color):
	"""Register one completion option. display_text == what the popup shows and
	what Godot's prefix-filter matches against — keep it clean (no spaces/desc)."""
	code_input.add_code_completion_option(kind, display, insert, color)

func _on_run_button_pressed():
	# Set to normal run mode (no debug UI)
	debug_mode = false
	_hide_debug_ui()
	_reset_variant_state_for_new_run()
	_set_split_resize_enabled(false)
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	
	# Clear variables and log from previous execution
	_clear_variables()
	_clear_execution_log()
	
	# Start timing for execution log
	execution_start_time = Time.get_ticks_msec()
	
	var code = code_input.text
	output_label.text = "Running..."
	output_label.add_theme_color_override("font_color", Color(0.647, 0.671, 0.780, 1))
	run_button.disabled = true
	debug_button.disabled = true
	stop_button.disabled = false
	player.reset_position()
	code_executor.execute_code(code, player)
	# Apply the current speed setting to the freshly-started interpreter
	if code_executor.interpreter:
		code_executor.interpreter.set_execution_speed(_exec_speed)

func _on_debug_button_pressed():
	# Set to debug mode (show debug UI)
	debug_mode = true
	_show_debug_ui()
	_reset_variant_state_for_new_run()
	_set_split_resize_enabled(false)
	
	# Reset level state
	is_level_complete = false
	player_is_dead = false
	
	# Clear variables and log from previous execution
	_clear_variables()
	_clear_execution_log()
	
	# Start timing for execution log
	execution_start_time = Time.get_ticks_msec()
	
	var code = code_input.text
	output_label.text = "Debugging..."
	output_label.add_theme_color_override("font_color", Color(0.88, 0.70, 0.35, 1))
	run_button.disabled = true
	debug_button.disabled = true
	stop_button.disabled = false
	player.reset_position()
	code_executor.execute_code(code, player)
	# Apply the current speed setting to the freshly-started interpreter
	if code_executor.interpreter:
		code_executor.interpreter.set_execution_speed(_exec_speed)

func _on_stop_button_pressed():
	"""Stop the currently executing code"""
	_rerun_after_variant = false
	code_executor.stop_execution()
	_set_split_resize_enabled(true)
	output_label.text = "Stopped."
	output_label.add_theme_color_override("font_color", Color(0.647, 0.671, 0.780, 1))
	run_button.disabled = false
	debug_button.disabled = false
	stop_button.disabled = true
	_set_split_resize_enabled(true)
	_set_variant_bar_interactive(true)
	player.reset_position()

func _on_execution_complete():
	# If a variant was just cleared, re-run the same code on the next variant
	# grid (which GridManager already loaded before emitting variant_advanced).
	if _rerun_after_variant:
		_rerun_after_variant = false
		_reset_player_and_refresh_grid(false)
		var code = code_input.text
		output_label.add_theme_color_override("font_color", Color(0.647, 0.671, 0.780, 1))
		code_executor.execute_code(code, player)
		if code_executor.interpreter:
			code_executor.interpreter.set_execution_speed(_exec_speed)
		return

	if not player_is_dead and player and player.is_on_goal():
		output_label.text = "Level complete! All variants solved!"
		output_label.add_theme_color_override("font_color", Color(0.40, 0.90, 0.55, 1))
		next_level_button.disabled = false
		_win_popup.show_result()
	elif player_is_dead:
		output_label.text = "You died — press Restart to try again."
		output_label.add_theme_color_override("font_color", Color(0.98, 0.55, 0.35, 1))
	else:
		output_label.text = "Done."
		output_label.add_theme_color_override("font_color", Color(0.647, 0.671, 0.780, 1))
	run_button.disabled = false
	debug_button.disabled = false
	stop_button.disabled = true
	_set_split_resize_enabled(true)
	_set_variant_bar_interactive(true)

	# Clear line highlighting after execution
	if current_line_highlight >= 0:
		code_input.set_line_background_color(current_line_highlight, Color.TRANSPARENT)
		current_line_highlight = -1

func _on_restart_button_pressed():
	"""Restart the current level. Dispatch by source so custom levels reload
	from their cached dict rather than failing the level_definitions lookup."""
	# Stop any in-flight execution first to avoid the old run racing the new level.
	if code_executor:
		code_executor.stop_execution()
	_set_split_resize_enabled(true)
	if current_level_source == "builtin":
		load_level(current_level_id)
	else:
		_load_custom_level(current_level_dict)

func _on_next_level_button_pressed():
	"""Load next level. For custom levels there's no 'next' — fall back to
	the Custom Levels list instead of advancing past the end of builtins."""
	if current_level_source != "builtin":
		get_tree().change_scene_to_file("res://scenes/ui/custom_levels.tscn")
		return
	var next_level = current_level_id + 1
	if next_level <= level_definitions.get_level_count():
		load_level(next_level)
	else:
		output_label.text = "All levels complete — well done!"
		output_label.add_theme_color_override("font_color", Color(0.40, 0.90, 0.55, 1))
		next_level_button.disabled = true

func _on_menu_button_pressed():
	"""Return to main menu"""
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")

func _on_execution_error(error_msg: String):
	"""Handle execution errors with proper formatting"""
	_rerun_after_variant = false
	output_label.text = "Error: " + error_msg
	output_label.add_theme_color_override("font_color", Color(0.95, 0.38, 0.38, 1))

	run_button.disabled = false
	debug_button.disabled = false
	stop_button.disabled = true
	_set_variant_bar_interactive(true)

	Dbg.p("ERROR: %s" % error_msg)

func _on_level_completed():
	"""Called when player reaches goal"""
	is_level_complete = true
	Dbg.p("🎉 Level completed!")

func _on_player_died():
	"""Called when player hits hazard"""
	player_is_dead = true
	code_executor.stop_execution()
	_set_split_resize_enabled(true)
	Dbg.p("💀 Player died!")

func _set_split_resize_enabled(enabled: bool) -> void:
	"""Enable/disable dragging of both main splitters during execution."""
	_split_locked = not enabled
	if _split_locked:
		if hsplit_container:
			_locked_hsplit_offset = hsplit_container.split_offset
		if vsplit_container:
			_locked_vsplit_offset = vsplit_container.split_offset
	var mode := Control.MOUSE_FILTER_PASS if enabled else Control.MOUSE_FILTER_IGNORE
	if hsplit_container:
		hsplit_container.mouse_filter = mode
	if vsplit_container:
		vsplit_container.mouse_filter = mode
	if _split_locked:
		_enforce_split_lock()

func _enforce_split_lock() -> void:
	if hsplit_container and hsplit_container.split_offset != _locked_hsplit_offset:
		hsplit_container.split_offset = _locked_hsplit_offset
	if vsplit_container and vsplit_container.split_offset != _locked_vsplit_offset:
		vsplit_container.split_offset = _locked_vsplit_offset

func _update_help_text():
	output_label.text = """Movement Commands:
move() - Move forward
turnRight() - Turn 90° clockwise
turnLeft() - Turn 90° counter-clockwise
turnBack() - Turn around

Sensors:
frontIsClear(), leftIsClear(), rightIsClear()
goalReached(), onHazard()

Control Flow:
if/elif/else, for, while, do-while

Click Run to execute!"""


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
	
	Dbg.p("DEBUG: Execution highlighting and breakpoints enabled!")

func _on_gutter_clicked(line: int, gutter: int):
	"""Handle gutter clicks for breakpoint toggling"""
	if gutter == 0:  # Breakpoint gutter
		if debug_manager:
			debug_manager.toggle_breakpoint(line + 1)  # +1 because lines are 1-indexed in our system
			_update_breakpoint_display(line)
			Dbg.p("DEBUG: Breakpoint toggled at line %d" % (line + 1))

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
	variables_scroll.custom_minimum_size = Vector2(150, 80)
	variables_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(variables_scroll)
	
	# Create VBoxContainer to hold variable labels
	variables_list = VBoxContainer.new()
	variables_list.name = "VariablesList"
	variables_scroll.add_child(variables_list)
	
	# Position the panel in the debug section (resizable)
	var debug_section = get_node("HSplitContainer/CodePanel/VSplitContainer/DebugSection")
	debug_section.add_child(variables_panel)
	
	# Hide panel by default (show only in debug mode)
	variables_panel.visible = false
	
	Dbg.p("DEBUG: Variable viewer UI created!")

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
	execution_log_scroll.custom_minimum_size = Vector2(150, 100)
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
	var debug_section = get_node("HSplitContainer/CodePanel/VSplitContainer/DebugSection")
	debug_section.add_child(execution_log_panel)
	
	# Hide panel by default (show only in debug mode)
	execution_log_panel.visible = false
	
	Dbg.p("DEBUG: Execution log UI created!")

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
	
	# Create flow container that wraps to multiple lines when needed
	var flow = HFlowContainer.new()
	flow.add_theme_constant_override("h_separation", 8)
	flow.add_theme_constant_override("v_separation", 4)
	debug_toolbar.add_child(flow)
	
	# Add label
	var toolbar_label = Label.new()
	toolbar_label.text = "Debug Controls:"
	toolbar_label.add_theme_font_size_override("font_size", 14)
	toolbar_label.add_theme_color_override("font_color", Color.CYAN)
	flow.add_child(toolbar_label)
	
	# Add separator
	var sep1 = VSeparator.new()
	flow.add_child(sep1)
	
	# Pause button
	pause_btn = Button.new()
	pause_btn.text = "⏸ Pause"
	pause_btn.custom_minimum_size = Vector2(80, 30)
	pause_btn.pressed.connect(_on_pause_pressed)
	flow.add_child(pause_btn)
	
	# Resume button
	resume_btn = Button.new()
	resume_btn.text = "▶ Resume"
	resume_btn.custom_minimum_size = Vector2(80, 30)
	resume_btn.disabled = true
	resume_btn.pressed.connect(_on_resume_pressed)
	flow.add_child(resume_btn)
	
	# Add separator
	var sep2 = VSeparator.new()
	flow.add_child(sep2)
	
	# Step Over button
	step_over_btn = Button.new()
	step_over_btn.text = "⤵ Step Over"
	step_over_btn.custom_minimum_size = Vector2(100, 30)
	step_over_btn.pressed.connect(_on_step_over_pressed)
	flow.add_child(step_over_btn)
	
	# Step Into button
	step_into_btn = Button.new()
	step_into_btn.text = "↓ Step Into"
	step_into_btn.custom_minimum_size = Vector2(100, 30)
	step_into_btn.pressed.connect(_on_step_into_pressed)
	flow.add_child(step_into_btn)
	
	# Step Out button
	step_out_btn = Button.new()
	step_out_btn.text = "↑ Step Out"
	step_out_btn.custom_minimum_size = Vector2(100, 30)
	step_out_btn.pressed.connect(_on_step_out_pressed)
	flow.add_child(step_out_btn)
	
	# Add separator
	var sep3 = VSeparator.new()
	flow.add_child(sep3)
	
	# Speed control label
	speed_label = Label.new()
	speed_label.text = "Speed: 1.0x"
	speed_label.add_theme_font_size_override("font_size", 12)
	flow.add_child(speed_label)
	
	# Speed slider
	speed_slider = HSlider.new()
	speed_slider.min_value = 0.25
	speed_slider.max_value = 5.0
	speed_slider.step = 0.25
	speed_slider.value = 1.0
	speed_slider.custom_minimum_size = Vector2(150, 20)
	speed_slider.value_changed.connect(_on_speed_changed)
	flow.add_child(speed_slider)
	
	# Speed preset buttons
	var preset_container = HBoxContainer.new()
	preset_container.add_theme_constant_override("separation", 4)
	flow.add_child(preset_container)
	
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
	var code_panel = get_node("HSplitContainer/CodePanel/VSplitContainer/TopSection")
	var button_container = code_panel.get_node("ButtonContainer")
	var button_idx = button_container.get_index()
	code_panel.add_child(debug_toolbar)
	code_panel.move_child(debug_toolbar, button_idx + 1)
	
	Dbg.p("DEBUG: Debug toolbar created!")
	
	# Hide debug toolbar by default (only show in debug mode)
	debug_toolbar.visible = false

func _setup_help_system():
	"""Create help button and popup with command reference"""
	# Create debug button with orange/amber styling
	debug_button = Button.new()
	debug_button.text = "🐞 Debug"
	debug_button.custom_minimum_size = Vector2(72, 24)
	debug_button.add_theme_font_size_override("font_size", 12)
	debug_button.pressed.connect(_on_debug_button_pressed)
	
	# Apply orange/amber theme
	var debug_normal = StyleBoxFlat.new()
	debug_normal.bg_color = Color(0.8, 0.5, 0.1)  # Orange
	debug_normal.corner_radius_top_left = 4
	debug_normal.corner_radius_top_right = 4
	debug_normal.corner_radius_bottom_left = 4
	debug_normal.corner_radius_bottom_right = 4
	debug_button.add_theme_stylebox_override("normal", debug_normal)
	
	var debug_hover = StyleBoxFlat.new()
	debug_hover.bg_color = Color(0.95, 0.6, 0.15)  # Lighter orange
	debug_hover.corner_radius_top_left = 4
	debug_hover.corner_radius_top_right = 4
	debug_hover.corner_radius_bottom_left = 4
	debug_hover.corner_radius_bottom_right = 4
	debug_button.add_theme_stylebox_override("hover", debug_hover)
	debug_button.add_theme_stylebox_override("pressed", debug_hover)
	
	# Add to button container (right after Run button)
	var button_container = get_node("HSplitContainer/CodePanel/VSplitContainer/TopSection/ButtonContainer")
	button_container.add_child(debug_button)
	button_container.move_child(debug_button, 3)  # After Run button (position 3)
	
	# Create help button
	help_button = Button.new()
	help_button.text = "❓ Help"
	help_button.custom_minimum_size = Vector2(80, 30)
	help_button.pressed.connect(_on_help_button_pressed)
	
	# Add to button container
	button_container.add_child(help_button)
	
	# Create theme toggle button
	theme_toggle_button = Button.new()
	theme_toggle_button.text = "☀️ Light"
	theme_toggle_button.custom_minimum_size = Vector2(80, 30)
	theme_toggle_button.pressed.connect(_on_theme_toggle_pressed)
	
	# Add to button container
	button_container.add_child(theme_toggle_button)
	
	# Create popup panel
	help_popup = PopupPanel.new()
	help_popup.name = "HelpPopup"
	help_popup.size = Vector2(600, 500)
	help_popup.position = Vector2(300, 100)
	add_child(help_popup)
	
	# Create scroll container for help content
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(580, 480)
	help_popup.add_child(scroll)
	
	# Create VBoxContainer for layout
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	scroll.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "📚 Command Reference"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color.CYAN)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	# Separator
	var sep1 = HSeparator.new()
	vbox.add_child(sep1)
	
	# Movement Commands Section
	var movement_header = Label.new()
	movement_header.text = "🎮 Movement Commands"
	movement_header.add_theme_font_size_override("font_size", 18)
	movement_header.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(movement_header)
	
	var movement_text = Label.new()
	movement_text.text = """• move() - Move forward one cell in current direction
• turnRight() - Turn 90 degrees clockwise
• turnLeft() - Turn 90 degrees counter-clockwise
• turnBack() - Turn around 180 degrees"""
	movement_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(movement_text)
	
	# Sensors Section
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	var sensors_header = Label.new()
	sensors_header.text = "🔍 Sensors"
	sensors_header.add_theme_font_size_override("font_size", 18)
	sensors_header.add_theme_color_override("font_color", Color.GREEN)
	vbox.add_child(sensors_header)
	
	var sensors_text = Label.new()
	sensors_text.text = """• frontIsClear() - Returns true if front cell is walkable
• leftIsClear() - Returns true if left cell is walkable
• rightIsClear() - Returns true if right cell is walkable
• goalReached() - Returns true if standing on goal
• onHazard() - Returns true if standing on hazard"""
	sensors_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(sensors_text)
	
	# Control Flow Section
	var sep3 = HSeparator.new()
	vbox.add_child(sep3)
	
	var control_header = Label.new()
	control_header.text = "🔄 Control Flow"
	control_header.add_theme_font_size_override("font_size", 18)
	control_header.add_theme_color_override("font_color", Color.ORANGE)
	vbox.add_child(control_header)
	
	var control_text = Label.new()
	control_text.text = """• if (condition) { ... } - Execute if condition is true
• elif (condition) { ... } - Check another condition
• else { ... } - Execute if all conditions false
• for (i in range(n)) { ... } - Repeat n times
• while (condition) { ... } - Repeat while condition true
• function name() { ... } - Define reusable code"""
	control_text.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(control_text)
	
	# Examples Section
	var sep4 = HSeparator.new()
	vbox.add_child(sep4)
	
	var examples_header = Label.new()
	examples_header.text = "💡 Examples"
	examples_header.add_theme_font_size_override("font_size", 18)
	examples_header.add_theme_color_override("font_color", Color.MAGENTA)
	vbox.add_child(examples_header)
	
	var example1 = Label.new()
	example1.text = """Example 1: Simple Movement
move()
move()
turnRight()
move()"""
	# Only add font if it exists
	if ResourceLoader.exists("res://fonts/code_font.tres"):
		example1.add_theme_font_override("font", load("res://fonts/code_font.tres"))
	example1.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(example1)
	
	var example2 = Label.new()
	example2.text = """Example 2: Navigate with Sensors
while (frontIsClear()) {
	move()
}
turnRight()
while (frontIsClear()) {
	move()
}"""
	# Only add font if it exists
	if ResourceLoader.exists("res://fonts/code_font.tres"):
		example2.add_theme_font_override("font", load("res://fonts/code_font.tres"))
	example2.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(example2)
	
	var example3 = Label.new()
	example3.text = """Example 3: Function with Loop
function square() {
	for (i in range(4)) {
		move()
		turnRight()
	}
}

square()"""
	# Only add font if it exists
	if ResourceLoader.exists("res://fonts/code_font.tres"):
		example3.add_theme_font_override("font", load("res://fonts/code_font.tres"))
	example3.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(example3)
	
	# Close button
	var sep5 = HSeparator.new()
	vbox.add_child(sep5)
	
	var close_btn = Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(100, 40)
	close_btn.pressed.connect(_on_help_close_pressed)
	vbox.add_child(close_btn)
	
	Dbg.p("DEBUG: Help system created!")

func _on_help_button_pressed():
	"""Show the help popup"""
	if help_popup:
		help_popup.popup_centered()

func _on_help_close_pressed():
	"""Hide the help popup"""
	if help_popup:
		help_popup.hide()

func _on_line_executing(line_number: int):
	"""Called when a line is about to be executed"""
	Dbg.p("DEBUG: Highlighting line %d" % line_number)
	
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
		Dbg.p("DEBUG: Applied highlight to line %d with color %s" % [editor_line, highlight_color])
		
		# Scroll to current line
		code_input.set_caret_line(editor_line)
		code_input.center_viewport_to_caret()
	else:
		Dbg.p("DEBUG: Line %d out of range (total lines: %d)" % [editor_line, code_input.get_line_count()])


func _on_variable_changed(var_name: String, value):
	"""Called when a variable value changes"""
	Dbg.p("DEBUG: Variable changed: %s = %s" % [var_name, str(value)])
	
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
	var var_label = variable_labels[var_name]
	var value_str = str(value)
	var_label.text = "%s = %s" % [var_name, value_str]
	
	# Highlight changed variable briefly
	var_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Reset color after a short delay
	await get_tree().create_timer(0.5).timeout
	if var_label and is_instance_valid(var_label):
		var_label.add_theme_color_override("font_color", Color.WHITE)

func _on_function_entered(func_name: String, params: Dictionary):
	"""Called when entering a function"""
	Dbg.p("DEBUG: Entering function: %s" % func_name)
	
	# Format parameters for log
	var params_str = []
	for key in params:
		params_str.append("%s=%s" % [key, str(params[key])])
	var params_display = ", ".join(params_str) if params_str.size() > 0 else ""
	
	# Add to execution log (always update data)
	_add_log_entry("[color=green]→ Entering[/color] %s(%s)" % [func_name, params_display])

func _on_function_exited(func_name: String, return_value):
	"""Called when exiting a function"""
	Dbg.p("DEBUG: Exiting function: %s (returned: %s)" % [func_name, str(return_value)])
	
	# Add to execution log
	_add_log_entry("[color=red]← Exiting[/color] %s (returned: %s)" % [func_name, str(return_value)])


func _clear_variables():
	"""Clear all variable labels from the viewer"""
	if not variables_list:
		return
	
	# Remove all child labels
	for child in variables_list.get_children():
		child.queue_free()
	
	# Clear the dictionary
	variable_labels.clear()
	
	Dbg.p("DEBUG: Variables cleared")

func _add_log_entry(text: String):
	"""Add an entry to the execution log with timestamp"""
	if not execution_log:
		Dbg.p("ERROR: execution_log is null!")
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
	
	Dbg.p("DEBUG: Added log entry at %.2fs" % elapsed_sec)
	
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
	
	Dbg.p("DEBUG: Execution log cleared")

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
	Dbg.p("  ".repeat(depth) + node.name + " (" + node.get_class() + ")")
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
		Dbg.p("DEBUG: Pause button pressed")

func _on_resume_pressed():
	"""Handle resume button press"""
	if debug_manager:
		debug_manager.resume()
		pause_btn.disabled = false
		resume_btn.disabled = true
		Dbg.p("DEBUG: Resume button pressed")

func _on_step_over_pressed():
	"""Handle step over button press"""
	if debug_manager:
		debug_manager.step_over()
		pause_btn.disabled = true
		resume_btn.disabled = false
		Dbg.p("DEBUG: Step over button pressed")

func _on_step_into_pressed():
	"""Handle step into button press"""
	if debug_manager:
		debug_manager.step_into()
		pause_btn.disabled = true
		resume_btn.disabled = false
		Dbg.p("DEBUG: Step into button pressed")

func _on_step_out_pressed():
	"""Handle step out button press"""
	if debug_manager:
		debug_manager.step_out()
		pause_btn.disabled = true
		resume_btn.disabled = false
		Dbg.p("DEBUG: Step out button pressed")

func _on_speed_changed(value: float):
	"""Handle debug speed slider change — syncs to shared _exec_speed."""
	_exec_speed = value
	var interpreter = code_executor.interpreter
	if interpreter:
		interpreter.set_execution_speed(value)
	speed_label.text = "Speed: %.2fx" % [value]
	# Keep toolbar slider in sync
	if _speed_label_toolbar:
		_speed_label_toolbar.text = str(snapped(value, 0.01)) + "\u00d7"
	Dbg.p("DEBUG: Speed changed to %.2fx" % [value])

func _set_speed_preset(speed: float):
	"""Set speed to a preset value"""
	speed_slider.value = speed
	# _on_speed_changed will be called automatically

# ============================================
# Debug Mode UI Control
# ============================================

func _show_debug_ui():
	"""Show all debug panels and toolbar"""
	if debug_toolbar:
		debug_toolbar.visible = true
	if variables_panel:
		variables_panel.visible = true
	if execution_log_panel:
		execution_log_panel.visible = true
	Dbg.p("DEBUG: Debug UI shown")

func _hide_debug_ui():
	"""Hide all debug panels and toolbar"""
	if debug_toolbar:
		debug_toolbar.visible = false
	if variables_panel:
		variables_panel.visible = false
	if execution_log_panel:
		execution_log_panel.visible = false
	Dbg.p("DEBUG: Debug UI hidden")

func _on_theme_toggle_pressed():
	"""Toggle between dark and light themes"""
	is_dark_mode = not is_dark_mode
	_apply_theme()

func _apply_theme():
	"""Apply the current theme (dark or light) to all UI elements"""
	var code_panel = get_node("HSplitContainer/CodePanel")

	if is_dark_mode:
		theme_toggle_button.text = "Light"

		# Code panel background
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color          = Color(0.075, 0.082, 0.118, 1)
		panel_style.border_width_right = 1
		panel_style.border_color       = Color(0.18, 0.20, 0.30, 1)
		code_panel.add_theme_stylebox_override("panel", panel_style)

		# Code editor
		code_input.add_theme_color_override("background_color",   Color(0.063, 0.067, 0.098, 1))
		code_input.add_theme_color_override("font_color",          Color(0.875, 0.882, 0.957, 1))
		code_input.add_theme_color_override("current_line_color",  Color(0.133, 0.141, 0.208, 1))
		code_input.add_theme_color_override("caret_color",         Color(0.388, 0.898, 0.588, 1))
		code_input.add_theme_color_override("line_number_color",   Color(0.357, 0.388, 0.510, 1))
		code_input.add_theme_color_override("selection_color",     Color(0.173, 0.275, 0.494, 0.8))

		# Title
		title_label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.98, 1))

		# Output console (only clear color; panel bg is set in scene)
		output_label.add_theme_color_override("font_color", Color(0.647, 0.671, 0.780, 1))

	else:
		theme_toggle_button.text = "Dark"

		# Code panel background
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color           = Color(0.96, 0.96, 0.98, 1)
		panel_style.border_width_right = 1
		panel_style.border_color       = Color(0.72, 0.72, 0.78, 1)
		code_panel.add_theme_stylebox_override("panel", panel_style)

		# Code editor
		code_input.add_theme_color_override("background_color",  Color(1.0, 1.0, 1.0, 1))
		code_input.add_theme_color_override("font_color",         Color(0.12, 0.12, 0.14, 1))
		code_input.add_theme_color_override("current_line_color", Color(0.94, 0.95, 0.98, 1))
		code_input.add_theme_color_override("caret_color",        Color(0.10, 0.50, 0.30, 1))
		code_input.add_theme_color_override("line_number_color",  Color(0.50, 0.52, 0.58, 1))
		code_input.add_theme_color_override("selection_color",    Color(0.71, 0.83, 1.00, 0.8))

		# Title
		title_label.add_theme_color_override("font_color", Color(0.14, 0.16, 0.26, 1))

		# Output console
		output_label.add_theme_color_override("font_color", Color(0.20, 0.22, 0.32, 1))

	# Reapply syntax highlighting with theme colors
	_setup_syntax_highlighting()

func _setup_syntax_highlighting():
	"""Setup syntax highlighting for code editor"""
	syntax_highlighter = CodeHighlighter.new()
	
	# Define colors based on current theme
	var keyword_color: Color
	var function_color: Color
	var string_color: Color
	var number_color: Color
	var comment_color: Color
	var symbol_color: Color
	
	if is_dark_mode:
		# Dark — Catppuccin-inspired
		keyword_color  = Color(0.82, 0.38, 0.72, 1.0)  # Mauve/pink  — if/for/while
		function_color = Color(0.33, 0.80, 0.98, 1.0)  # Sky blue    — move/turn
		string_color   = Color(0.65, 0.87, 0.40, 1.0)  # Green       — strings
		number_color   = Color(0.98, 0.73, 0.42, 1.0)  # Peach       — numbers
		comment_color  = Color(0.35, 0.40, 0.52, 1.0)  # Muted blue  — comments
		symbol_color   = Color(0.72, 0.74, 0.88, 1.0)  # Lavender    — symbols
	else:
		# Light — VS Code Light-inspired
		keyword_color  = Color(0.53, 0.07, 0.62, 1.0)  # Purple
		function_color = Color(0.00, 0.33, 0.72, 1.0)  # Dark blue
		string_color   = Color(0.18, 0.47, 0.08, 1.0)  # Forest green
		number_color   = Color(0.62, 0.26, 0.00, 1.0)  # Dark orange
		comment_color  = Color(0.38, 0.42, 0.46, 1.0)  # Steel gray
		symbol_color   = Color(0.24, 0.26, 0.30, 1.0)  # Near-black
	
	# Control flow keywords (purple)
	syntax_highlighter.add_keyword_color("if", keyword_color)
	syntax_highlighter.add_keyword_color("else", keyword_color)
	syntax_highlighter.add_keyword_color("elif", keyword_color)
	syntax_highlighter.add_keyword_color("for", keyword_color)
	syntax_highlighter.add_keyword_color("while", keyword_color)
	syntax_highlighter.add_keyword_color("function", keyword_color)
	syntax_highlighter.add_keyword_color("return", keyword_color)
	syntax_highlighter.add_keyword_color("break", keyword_color)
	syntax_highlighter.add_keyword_color("continue", keyword_color)
	syntax_highlighter.add_keyword_color("true", keyword_color)
	syntax_highlighter.add_keyword_color("false", keyword_color)
	syntax_highlighter.add_keyword_color("null", keyword_color)
	
	# Movement commands (cyan)
	syntax_highlighter.add_keyword_color("move", function_color)
	syntax_highlighter.add_keyword_color("turnRight", function_color)
	syntax_highlighter.add_keyword_color("turnLeft", function_color)
	syntax_highlighter.add_keyword_color("turnBack", function_color)
	
	# Sensor functions (cyan)
	syntax_highlighter.add_keyword_color("frontIsClear", function_color)
	syntax_highlighter.add_keyword_color("leftIsClear", function_color)
	syntax_highlighter.add_keyword_color("rightIsClear", function_color)
	syntax_highlighter.add_keyword_color("backIsClear", function_color)
	syntax_highlighter.add_keyword_color("onGoal", function_color)
	syntax_highlighter.add_keyword_color("goalReached", function_color)
	syntax_highlighter.add_keyword_color("onHazard", function_color)
	
	# Special operators
	syntax_highlighter.add_keyword_color("and", keyword_color)
	syntax_highlighter.add_keyword_color("or", keyword_color)
	syntax_highlighter.add_keyword_color("not", keyword_color)
	
	# Number and string coloring
	syntax_highlighter.number_color = number_color
	syntax_highlighter.symbol_color = symbol_color  # Brackets, parentheses, operators
	syntax_highlighter.add_color_region('"', '"', string_color)
	syntax_highlighter.add_color_region("'", "'", string_color)
	syntax_highlighter.add_color_region("#", "", comment_color, true)  # Line comments
	
	# Apply to code editor
	code_input.syntax_highlighter = syntax_highlighter

	Dbg.p("✨ Syntax highlighting updated:")
	Dbg.p("  Theme: %s" % ("DARK" if is_dark_mode else "LIGHT"))
	Dbg.p("  Keywords: %s" % keyword_color)
	Dbg.p("  Functions: %s" % function_color)
	Dbg.p("  Strings: %s" % string_color)
	Dbg.p("  Symbols: %s" % symbol_color)

# ============================================
# Editor Toolbar  (zoom + completion toggle)
# ============================================

func _setup_editor_toolbar():
	"""Create the thin zoom / hints toolbar row under the button bar."""
	var panel := PanelContainer.new()
	panel.name = "EditorToolbar"
	var style := StyleBoxFlat.new()
	style.bg_color              = Color(0.047, 0.051, 0.078, 0.95)
	style.border_width_bottom   = 1
	style.border_color          = Color(0.18, 0.20, 0.30, 0.5)
	style.content_margin_left   = 6.0
	style.content_margin_right  = 6.0
	style.content_margin_top    = 3.0
	style.content_margin_bottom = 3.0
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	panel.add_child(hbox)

	# ── Zoom out ────────────────────────────────────────────────
	var zoom_out_btn := Button.new()
	zoom_out_btn.text               = "A−"
	zoom_out_btn.flat               = true
	zoom_out_btn.custom_minimum_size = Vector2(32, 22)
	zoom_out_btn.tooltip_text       = "Decrease font size  (Ctrl + Scroll ↓)"
	zoom_out_btn.pressed.connect(_zoom_out)
	hbox.add_child(zoom_out_btn)

	# ── Size label ──────────────────────────────────────────────
	_zoom_label = Label.new()
	_zoom_label.text                = "%dpx" % editor_font_size
	_zoom_label.custom_minimum_size = Vector2(40, 0)
	_zoom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_zoom_label.add_theme_font_size_override("font_size", 11)
	_zoom_label.add_theme_color_override("font_color", Color(0.50, 0.53, 0.65, 1))
	hbox.add_child(_zoom_label)

	# ── Zoom in ─────────────────────────────────────────────────
	var zoom_in_btn := Button.new()
	zoom_in_btn.text               = "A+"
	zoom_in_btn.flat               = true
	zoom_in_btn.custom_minimum_size = Vector2(32, 22)
	zoom_in_btn.tooltip_text       = "Increase font size  (Ctrl + Scroll ↑)"
	zoom_in_btn.pressed.connect(_zoom_in)
	hbox.add_child(zoom_in_btn)

	# ── Separator ───────────────────────────────────────────────
	hbox.add_child(VSeparator.new())

	# ── Hints toggle ────────────────────────────────────────────
	_hints_btn = Button.new()
	_hints_btn.text               = "💡 Hints  ON"
	_hints_btn.flat               = true
	_hints_btn.custom_minimum_size = Vector2(100, 22)
	_hints_btn.tooltip_text       = "Toggle code completion suggestions"
	_hints_btn.add_theme_color_override("font_color", Color(0.42, 0.90, 0.52, 1.0))
	_hints_btn.pressed.connect(_toggle_hints)
	hbox.add_child(_hints_btn)

	# ── Separator ───────────────────────────────────────────────
	hbox.add_child(VSeparator.new())

	# ── Speed label ─────────────────────────────────────────────
	var speed_lbl := Label.new()
	speed_lbl.text = "Speed:"
	speed_lbl.add_theme_font_size_override("font_size", 11)
	speed_lbl.add_theme_color_override("font_color", Color(0.50, 0.53, 0.65, 1))
	hbox.add_child(speed_lbl)

	# ── Speed slider ─────────────────────────────────────────────
	var speed_slider_tb := HSlider.new()
	speed_slider_tb.min_value        = 0.25
	speed_slider_tb.max_value        = 4.0
	speed_slider_tb.step             = 0.25
	speed_slider_tb.value            = _exec_speed
	speed_slider_tb.custom_minimum_size = Vector2(110, 20)
	speed_slider_tb.tooltip_text     = "Execution speed (0.25× – 4×)"
	speed_slider_tb.value_changed.connect(_on_toolbar_speed_changed)
	hbox.add_child(speed_slider_tb)

	# ── Speed value label ────────────────────────────────────────
	_speed_label_toolbar = Label.new()
	_speed_label_toolbar.text = str(snapped(_exec_speed, 0.01)) + "\u00d7"
	_speed_label_toolbar.custom_minimum_size = Vector2(34, 0)
	_speed_label_toolbar.add_theme_font_size_override("font_size", 11)
	_speed_label_toolbar.add_theme_color_override("font_color", Color(0.70, 0.75, 0.90, 1))
	hbox.add_child(_speed_label_toolbar)

	# ── Spacer ──────────────────────────────────────────────────
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)

	# Insert right after the debug_toolbar (which is at button_idx + 1)
	var top_section := get_node("HSplitContainer/CodePanel/VSplitContainer/TopSection")
	top_section.add_child(panel)
	top_section.move_child(panel, debug_toolbar.get_index() + 1)

	# Apply the initial font size
	_apply_font_size()

	Dbg.p("DEBUG: Editor toolbar (zoom + hints + speed) created!")

func _zoom_in():
	"""Increase the code editor font size by one step."""
	editor_font_size = mini(editor_font_size + 1, FONT_SIZE_MAX)
	_apply_font_size()

func _zoom_out():
	"""Decrease the code editor font size by one step."""
	editor_font_size = maxi(editor_font_size - 1, FONT_SIZE_MIN)
	_apply_font_size()

func _apply_font_size():
	"""Push the current font size to the code editor and refresh the label."""
	code_input.add_theme_font_size_override("font_size", editor_font_size)
	if _zoom_label:
		_zoom_label.text = "%dpx" % editor_font_size

func _on_code_input_gui_input(event: InputEvent):
	"""Ctrl + scroll wheel → zoom the code editor."""
	if not (event is InputEventMouseButton) or not event.pressed or not event.ctrl_pressed:
		return
	match event.button_index:
		MOUSE_BUTTON_WHEEL_UP:
			_zoom_in()
			get_viewport().set_input_as_handled()
		MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_out()
			get_viewport().set_input_as_handled()

func _toggle_hints():
	"""Toggle code completion suggestions on / off."""
	_completion_on = not _completion_on
	code_input.code_completion_enabled = _completion_on
	if _hints_btn:
		if _completion_on:
			_hints_btn.text = "💡 Hints  ON"
			_hints_btn.add_theme_color_override("font_color", Color(0.42, 0.90, 0.52, 1.0))
		else:
			_hints_btn.text = "💡 Hints  OFF"
			_hints_btn.add_theme_color_override("font_color", Color(0.40, 0.42, 0.52, 1.0))

func _on_toolbar_speed_changed(value: float):
	"""Toolbar speed slider changed — applies immediately to any running execution."""
	_exec_speed = value
	if _speed_label_toolbar:
		_speed_label_toolbar.text = str(snapped(value, 0.01)) + "\u00d7"
	# Sync debug speed slider + its label
	if speed_slider:
		speed_slider.value = value
	if speed_label:
		speed_label.text = "Speed: %.2fx" % [value]
	# Apply to interpreter if currently running
	if code_executor and code_executor.interpreter:
		code_executor.interpreter.set_execution_speed(value)
