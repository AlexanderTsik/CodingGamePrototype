extends Control

# ── Scene nodes ───────────────────────────────────────────────────────────────
@onready var account_button  = $CenterContainer/Card/CardMargin/MenuBox/AccountButton
@onready var user_label      = $UserBar/UserBarInner/UserLabel
@onready var logout_button   = $UserBar/UserBarInner/LogoutButton

# Auth popup — built programmatically
var _auth_popup:      Panel
var _email_input:     LineEdit
var _password_input:  LineEdit
var _username_input:  LineEdit
var _status_label:    Label
var _submit_button:   Button
var _mode_label:      Label
var _toggle_mode_btn: Button
var _is_register_mode := false

func _ready():
	$CenterContainer/Card/CardMargin/MenuBox/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/Card/CardMargin/MenuBox/LevelSelectButton.pressed.connect(_on_level_select_pressed)
	$CenterContainer/Card/CardMargin/MenuBox/LevelEditorButton.pressed.connect(_on_level_editor_pressed)
	$CenterContainer/Card/CardMargin/MenuBox/CustomLevelsButton.pressed.connect(_on_custom_levels_pressed)
	$CenterContainer/Card/CardMargin/MenuBox/HowToPlayButton.pressed.connect(_on_how_to_play_pressed)
	$CenterContainer/Card/CardMargin/MenuBox/QuitButton.pressed.connect(_on_quit_pressed)
	$HowToPlayPopup/MarginContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_popup_pressed)

	# In the browser build (tab / iframe) quitting does nothing, so hide the button.
	if OS.get_name() == "Web":
		$CenterContainer/Card/CardMargin/MenuBox/QuitButton.visible = false

	account_button.pressed.connect(_on_account_pressed)
	logout_button.pressed.connect(_on_logout_pressed)

	_build_auth_popup()
	_refresh_user_bar()

	AuthManager.logged_in.connect(_on_logged_in)
	AuthManager.logged_out.connect(_on_logged_out)

	# When embedded in the platform website, auto-load the level from the URL.
	# We hide the menu UI immediately so the user doesn't see it flash.
	if OS.get_name() == "Web":
		var level_id: String = str(JavaScriptBridge.eval(
			"new URLSearchParams(window.location.search).get('level_id') || ''"))
		if level_id != "" and level_id != "null":
			_hide_menu_and_show_loading()
			_load_level_from_url(level_id)

# ── Deep-link from platform website ──────────────────────────────────────────

func _hide_menu_and_show_loading() -> void:
	"""Hide the main menu UI immediately and show a loading indicator.
	Called when ?level_id=… is present so the user doesn't see the menu flash."""
	$CenterContainer.visible = false
	$UserBar.visible = false

	var loading := Label.new()
	loading.name = "DeepLinkLoading"
	loading.text = "Loading level..."
	loading.add_theme_font_size_override("font_size", 24)
	loading.add_theme_color_override("font_color", Color(0.78, 0.84, 0.98, 1))
	loading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	loading.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(loading)

func _load_level_from_url(level_id: String) -> void:
	var level_data: Dictionary = await ApiClient.get_level(level_id)
	if level_data.is_empty() or level_data.has("error"):
		_show_deeplink_error("Could not load this level.\nThe link may be invalid or the level was removed.")
		return
	# Mark the source so the game knows how to restart / route the leaderboard.
	# IMPORTANT: do NOT overwrite level_id — the UUID is needed for the leaderboard.
	level_data["level_source"] = "community"
	get_tree().root.set_meta("custom_level", level_data)
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _show_deeplink_error(msg: String) -> void:
	"""Show an error in the loading indicator and fall back to the main menu."""
	var loading = get_node_or_null("DeepLinkLoading")
	if loading:
		loading.text = msg + "\n\nReturning to main menu..."
		loading.add_theme_color_override("font_color", Color(0.95, 0.55, 0.55, 1))
	await get_tree().create_timer(2.5).timeout
	if not is_inside_tree():
		return
	$CenterContainer.visible = true
	$UserBar.visible = true
	var l = get_node_or_null("DeepLinkLoading")
	if l:
		l.queue_free()

# ── Navigation ────────────────────────────────────────────────────────────────

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game/main.tscn")

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")

func _on_level_editor_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/level_editor.tscn")

func _on_custom_levels_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/custom_levels.tscn")

func _on_how_to_play_pressed():
	$HowToPlayPopup.visible = true

func _on_close_popup_pressed():
	$HowToPlayPopup.visible = false

func _on_quit_pressed():
	get_tree().quit()

# ── Auth popup ────────────────────────────────────────────────────────────────

func _on_account_pressed():
	if AuthManager.is_logged_in():
		_status_label.text = "Signed in as  %s" % AuthManager.get_username()
		_status_label.add_theme_color_override("font_color", Color(0.40, 0.90, 0.55, 1))
		_auth_popup.visible = true
		return
	_set_mode(false)
	_status_label.text   = ""
	_email_input.text    = ""
	_password_input.text = ""
	_username_input.text = ""
	_auth_popup.visible  = true
	_email_input.grab_focus()

func _on_logout_pressed():
	AuthManager.clear_session()

func _on_auth_submit():
	var email    = _email_input.text.strip_edges()
	var password = _password_input.text.strip_edges()

	if email.is_empty() or password.is_empty():
		_show_status("Please fill in email and password.", false)
		return

	if _is_register_mode:
		var username = _username_input.text.strip_edges()
		if username.is_empty():
			_show_status("Please choose a username.", false)
			return
		_show_status("Creating account...", true)
		_submit_button.disabled = true
		var res = await ApiClient.register(email, password, username)
		_submit_button.disabled = false
		if res.has("error") and not res.has("user"):
			_show_status(_parse_error(res), false)
		elif res.has("access_token"):
			_auth_popup.visible = false
		elif res.has("user"):
			_show_status("Account created! Check your email to confirm.", true)
	else:
		_show_status("Signing in...", true)
		_submit_button.disabled = true
		var res = await ApiClient.login(email, password)
		_submit_button.disabled = false
		if res.has("error"):
			_show_status(_parse_error(res), false)
		elif res.has("access_token"):
			_auth_popup.visible = false

func _on_toggle_mode():
	_set_mode(not _is_register_mode)

func _set_mode(register: bool):
	_is_register_mode = register
	if register:
		_mode_label.text      = "Create Account"
		_submit_button.text   = "Register"
		_toggle_mode_btn.text = "Already have an account?  Sign in"
		_username_input.visible = true
	else:
		_mode_label.text      = "Sign In"
		_submit_button.text   = "Sign In"
		_toggle_mode_btn.text = "No account yet?  Register"
		_username_input.visible = false
	_status_label.text = ""

func _show_status(msg: String, ok: bool):
	_status_label.text = msg
	var color = Color(0.40, 0.90, 0.55, 1) if ok else Color(0.95, 0.38, 0.38, 1)
	_status_label.add_theme_color_override("font_color", color)

func _parse_error(res: Dictionary) -> String:
	for key in ["msg", "message", "error_description"]:
		if res.has(key) and str(res[key]) != "":
			return str(res[key])
	return "Something went wrong. Please try again."

# ── Auth state callbacks ───────────────────────────────────────────────────────

func _on_logged_in(_username: String):
	_refresh_user_bar()
	account_button.text = "My Account"

func _on_logged_out():
	_refresh_user_bar()
	account_button.text = "Login / Register"

func _refresh_user_bar():
	if AuthManager.is_logged_in():
		user_label.text       = AuthManager.get_username()
		user_label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.98, 1))
		logout_button.visible = true
	else:
		user_label.text       = "Playing as guest"
		user_label.add_theme_color_override("font_color", Color(0.50, 0.54, 0.70, 1))
		logout_button.visible = false

# ── Build auth popup UI ───────────────────────────────────────────────────────

func _build_auth_popup():
	_auth_popup         = Panel.new()
	_auth_popup.name    = "AuthPopup"
	_auth_popup.visible = false

	# Styled panel background
	var popup_style = StyleBoxFlat.new()
	popup_style.bg_color               = Color(0.071, 0.075, 0.110, 1)
	popup_style.border_width_left      = 1
	popup_style.border_width_top       = 1
	popup_style.border_width_right     = 1
	popup_style.border_width_bottom    = 1
	popup_style.border_color           = Color(0.196, 0.212, 0.318, 1)
	popup_style.corner_radius_top_left     = 10
	popup_style.corner_radius_top_right    = 10
	popup_style.corner_radius_bottom_right = 10
	popup_style.corner_radius_bottom_left  = 10
	popup_style.shadow_color  = Color(0, 0, 0, 0.55)
	popup_style.shadow_size   = 22
	popup_style.shadow_offset = Vector2(0, 8)
	_auth_popup.add_theme_stylebox_override("panel", popup_style)

	_auth_popup.anchor_left     = 0.5
	_auth_popup.anchor_top      = 0.5
	_auth_popup.anchor_right    = 0.5
	_auth_popup.anchor_bottom   = 0.5
	_auth_popup.offset_left     = -210.0
	_auth_popup.offset_top      = -250.0
	_auth_popup.offset_right    =  210.0
	_auth_popup.offset_bottom   =  250.0
	_auth_popup.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_auth_popup.grow_vertical   = Control.GROW_DIRECTION_BOTH
	add_child(_auth_popup)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   28)
	margin.add_theme_constant_override("margin_right",  28)
	margin.add_theme_constant_override("margin_top",    28)
	margin.add_theme_constant_override("margin_bottom", 28)
	_auth_popup.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	margin.add_child(vbox)

	# Title
	_mode_label = Label.new()
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.add_theme_font_size_override("font_size", 20)
	_mode_label.add_theme_color_override("font_color", Color(0.78, 0.84, 0.98, 1))
	vbox.add_child(_mode_label)

	vbox.add_child(HSeparator.new())

	# Field style helper
	var _make_field_style = func() -> StyleBoxFlat:
		var s = StyleBoxFlat.new()
		s.bg_color            = Color(0.047, 0.051, 0.075, 1)
		s.border_width_left   = 1
		s.border_width_top    = 1
		s.border_width_right  = 1
		s.border_width_bottom = 1
		s.border_color        = Color(0.196, 0.212, 0.318, 1)
		s.corner_radius_top_left     = 5
		s.corner_radius_top_right    = 5
		s.corner_radius_bottom_right = 5
		s.corner_radius_bottom_left  = 5
		s.content_margin_left   = 8.0
		s.content_margin_right  = 8.0
		s.content_margin_top    = 6.0
		s.content_margin_bottom = 6.0
		return s

	# Email
	var email_lbl = Label.new()
	email_lbl.text = "Email"
	email_lbl.add_theme_font_size_override("font_size", 13)
	email_lbl.add_theme_color_override("font_color", Color(0.50, 0.54, 0.70, 1))
	vbox.add_child(email_lbl)

	_email_input = LineEdit.new()
	_email_input.placeholder_text    = "you@example.com"
	_email_input.custom_minimum_size = Vector2(0, 36)
	_email_input.add_theme_stylebox_override("normal", _make_field_style.call())
	vbox.add_child(_email_input)

	# Username (register only)
	var uname_lbl = Label.new()
	uname_lbl.text = "Username"
	uname_lbl.add_theme_font_size_override("font_size", 13)
	uname_lbl.add_theme_color_override("font_color", Color(0.50, 0.54, 0.70, 1))
	vbox.add_child(uname_lbl)

	_username_input = LineEdit.new()
	_username_input.placeholder_text    = "Choose a username"
	_username_input.custom_minimum_size = Vector2(0, 36)
	_username_input.add_theme_stylebox_override("normal", _make_field_style.call())
	vbox.add_child(_username_input)

	# Password
	var pw_lbl = Label.new()
	pw_lbl.text = "Password"
	pw_lbl.add_theme_font_size_override("font_size", 13)
	pw_lbl.add_theme_color_override("font_color", Color(0.50, 0.54, 0.70, 1))
	vbox.add_child(pw_lbl)

	_password_input = LineEdit.new()
	_password_input.placeholder_text    = "Password"
	_password_input.secret              = true
	_password_input.custom_minimum_size = Vector2(0, 36)
	_password_input.add_theme_stylebox_override("normal", _make_field_style.call())
	_password_input.text_submitted.connect(func(_t): _on_auth_submit())
	vbox.add_child(_password_input)

	# Status label
	_status_label = Label.new()
	_status_label.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size  = Vector2(0, 32)
	_status_label.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_status_label)

	# Primary button style
	var _btn_primary_style = func() -> StyleBoxFlat:
		var s = StyleBoxFlat.new()
		s.bg_color                   = Color(0.082, 0.467, 0.224, 1)
		s.corner_radius_top_left     = 6
		s.corner_radius_top_right    = 6
		s.corner_radius_bottom_right = 6
		s.corner_radius_bottom_left  = 6
		s.content_margin_left   = 12.0
		s.content_margin_right  = 12.0
		s.content_margin_top    = 6.0
		s.content_margin_bottom = 6.0
		return s

	var _btn_primary_hover = func() -> StyleBoxFlat:
		var s = StyleBoxFlat.new()
		s.bg_color                   = Color(0.106, 0.588, 0.282, 1)
		s.corner_radius_top_left     = 6
		s.corner_radius_top_right    = 6
		s.corner_radius_bottom_right = 6
		s.corner_radius_bottom_left  = 6
		s.content_margin_left   = 12.0
		s.content_margin_right  = 12.0
		s.content_margin_top    = 6.0
		s.content_margin_bottom = 6.0
		return s

	var _btn_flat_style = func() -> StyleBoxFlat:
		var s = StyleBoxFlat.new()
		s.bg_color                   = Color(0.102, 0.108, 0.157, 1)
		s.border_width_left          = 1
		s.border_width_top           = 1
		s.border_width_right         = 1
		s.border_width_bottom        = 1
		s.border_color               = Color(0.196, 0.212, 0.318, 1)
		s.corner_radius_top_left     = 6
		s.corner_radius_top_right    = 6
		s.corner_radius_bottom_right = 6
		s.corner_radius_bottom_left  = 6
		s.content_margin_left   = 12.0
		s.content_margin_right  = 12.0
		s.content_margin_top    = 6.0
		s.content_margin_bottom = 6.0
		return s

	var _btn_flat_hover = func() -> StyleBoxFlat:
		var s = StyleBoxFlat.new()
		s.bg_color                   = Color(0.145, 0.157, 0.231, 1)
		s.border_width_left          = 1
		s.border_width_top           = 1
		s.border_width_right         = 1
		s.border_width_bottom        = 1
		s.border_color               = Color(0.290, 0.318, 0.510, 1)
		s.corner_radius_top_left     = 6
		s.corner_radius_top_right    = 6
		s.corner_radius_bottom_right = 6
		s.corner_radius_bottom_left  = 6
		s.content_margin_left   = 12.0
		s.content_margin_right  = 12.0
		s.content_margin_top    = 6.0
		s.content_margin_bottom = 6.0
		return s

	# Submit button
	_submit_button = Button.new()
	_submit_button.custom_minimum_size = Vector2(0, 42)
	_submit_button.add_theme_font_size_override("font_size", 16)
	_submit_button.add_theme_stylebox_override("normal",  _btn_primary_style.call())
	_submit_button.add_theme_stylebox_override("hover",   _btn_primary_hover.call())
	_submit_button.add_theme_stylebox_override("pressed", _btn_primary_hover.call())
	_submit_button.pressed.connect(_on_auth_submit)
	vbox.add_child(_submit_button)

	# Toggle mode
	_toggle_mode_btn = Button.new()
	_toggle_mode_btn.add_theme_font_size_override("font_size", 13)
	_toggle_mode_btn.add_theme_color_override("font_color",       Color(0.42, 0.62, 0.95, 1))
	_toggle_mode_btn.add_theme_color_override("font_hover_color", Color(0.60, 0.78, 1.00, 1))
	_toggle_mode_btn.add_theme_stylebox_override("normal",  StyleBoxEmpty.new())
	_toggle_mode_btn.add_theme_stylebox_override("hover",   StyleBoxEmpty.new())
	_toggle_mode_btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	_toggle_mode_btn.pressed.connect(_on_toggle_mode)
	vbox.add_child(_toggle_mode_btn)

	# Cancel
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.add_theme_stylebox_override("normal",  _btn_flat_style.call())
	cancel_btn.add_theme_stylebox_override("hover",   _btn_flat_hover.call())
	cancel_btn.add_theme_stylebox_override("pressed", _btn_flat_hover.call())
	cancel_btn.pressed.connect(func(): _auth_popup.visible = false)
	vbox.add_child(cancel_btn)

	_set_mode(false)
