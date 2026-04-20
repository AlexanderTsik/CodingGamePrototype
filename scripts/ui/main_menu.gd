extends Control

# ── Scene nodes ───────────────────────────────────────────────────────────────
@onready var account_button  = $CenterContainer/VBoxContainer/AccountButton
@onready var user_label      = $UserBar/UserLabel
@onready var logout_button   = $UserBar/LogoutButton

# Auth popup — built programmatically below
var _auth_popup:      Panel
var _email_input:     LineEdit
var _password_input:  LineEdit
var _username_input:  LineEdit
var _status_label:    Label
var _submit_button:   Button
var _mode_label:      Label      # "Login" or "Register"
var _toggle_mode_btn: Button     # switch between modes
var _is_register_mode := false

func _ready():
	# Standard buttons
	$CenterContainer/VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$CenterContainer/VBoxContainer/LevelSelectButton.pressed.connect(_on_level_select_pressed)
	$CenterContainer/VBoxContainer/LevelEditorButton.pressed.connect(_on_level_editor_pressed)
	$CenterContainer/VBoxContainer/CustomLevelsButton.pressed.connect(_on_custom_levels_pressed)
	$CenterContainer/VBoxContainer/HowToPlayButton.pressed.connect(_on_how_to_play_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)
	$HowToPlayPopup/MarginContainer/VBoxContainer/CloseButton.pressed.connect(_on_close_popup_pressed)

	# Auth buttons
	account_button.pressed.connect(_on_account_pressed)
	logout_button.pressed.connect(_on_logout_pressed)

	# Auth popup (built in code so we don't need a separate scene)
	_build_auth_popup()

	# Reflect any existing session (e.g. after page refresh on web)
	_refresh_user_bar()

	# Listen for auth state changes
	AuthManager.logged_in.connect(_on_logged_in)
	AuthManager.logged_out.connect(_on_logged_out)

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
		# Already logged in — show account info instead
		_status_label.text = "Logged in as: %s" % AuthManager.get_username()
		_status_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
		_auth_popup.visible = true
		return
	_set_mode(false)   # default to login
	_status_label.text = ""
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
			# Email confirmation disabled — logged in immediately
			# Note: _create_profile inside ApiClient.register already calls set_session,
			# so this branch only fires if profile creation was skipped.
			_auth_popup.visible = false
		elif res.has("user"):
			# Email confirmation enabled — account created, awaiting confirmation
			_show_status("Account created! Check your email to confirm before logging in.", true)
	else:
		_show_status("Logging in...", true)
		_submit_button.disabled = true
		var res = await ApiClient.login(email, password)
		_submit_button.disabled = false
		if res.has("error"):
			_show_status(_parse_error(res), false)
		elif res.has("access_token"):
			# AuthManager.set_session is called inside ApiClient.login → _ensure_profile
			_auth_popup.visible = false

func _on_toggle_mode():
	_set_mode(not _is_register_mode)

func _set_mode(register: bool):
	_is_register_mode = register
	if register:
		_mode_label.text      = "Create Account"
		_submit_button.text   = "Register"
		_toggle_mode_btn.text = "Already have an account? Login"
		_username_input.visible = true
	else:
		_mode_label.text      = "Login"
		_submit_button.text   = "Login"
		_toggle_mode_btn.text = "No account yet? Register"
		_username_input.visible = false
	_status_label.text = ""

func _show_status(msg: String, ok: bool):
	_status_label.text = msg
	var color = Color(0.4, 1.0, 0.4) if ok else Color(1.0, 0.4, 0.4)
	_status_label.add_theme_color_override("font_color", color)

func _parse_error(res: Dictionary) -> String:
	for key in ["msg", "message", "error_description"]:
		if res.has(key) and str(res[key]) != "":
			return str(res[key])
	return "Something went wrong. Please try again."

# ── Auth state callbacks ───────────────────────────────────────────────────────

func _on_logged_in(_username: String):
	_refresh_user_bar()
	account_button.text = "👤 My Account"

func _on_logged_out():
	_refresh_user_bar()
	account_button.text = "👤 Login / Register"

func _refresh_user_bar():
	if AuthManager.is_logged_in():
		user_label.text      = AuthManager.get_username()
		logout_button.visible = true
	else:
		user_label.text      = "Playing as guest"
		logout_button.visible = false

# ── Build auth popup UI ───────────────────────────────────────────────────────

func _build_auth_popup():
	_auth_popup = Panel.new()
	_auth_popup.name            = "AuthPopup"
	_auth_popup.visible         = false
	_auth_popup.anchors_preset  = Control.PRESET_CENTER
	_auth_popup.anchor_left     = 0.5
	_auth_popup.anchor_top      = 0.5
	_auth_popup.anchor_right    = 0.5
	_auth_popup.anchor_bottom   = 0.5
	_auth_popup.offset_left     = -200.0
	_auth_popup.offset_top      = -240.0
	_auth_popup.offset_right    = 200.0
	_auth_popup.offset_bottom   = 240.0
	_auth_popup.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_auth_popup.grow_vertical   = Control.GROW_DIRECTION_BOTH
	add_child(_auth_popup)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   24)
	margin.add_theme_constant_override("margin_right",  24)
	margin.add_theme_constant_override("margin_top",    24)
	margin.add_theme_constant_override("margin_bottom", 24)
	_auth_popup.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	# Title
	_mode_label = Label.new()
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.add_theme_font_size_override("font_size", 22)
	vbox.add_child(_mode_label)

	# Email
	var email_lbl = Label.new()
	email_lbl.text = "Email"
	vbox.add_child(email_lbl)

	_email_input = LineEdit.new()
	_email_input.placeholder_text    = "you@example.com"
	_email_input.custom_minimum_size = Vector2(0, 36)
	vbox.add_child(_email_input)

	# Username (register only)
	var uname_lbl = Label.new()
	uname_lbl.text = "Username"
	vbox.add_child(uname_lbl)

	_username_input = LineEdit.new()
	_username_input.placeholder_text    = "Choose a username"
	_username_input.custom_minimum_size = Vector2(0, 36)
	vbox.add_child(_username_input)

	# Password
	var pw_lbl = Label.new()
	pw_lbl.text = "Password"
	vbox.add_child(pw_lbl)

	_password_input = LineEdit.new()
	_password_input.placeholder_text    = "Password"
	_password_input.secret              = true
	_password_input.custom_minimum_size = Vector2(0, 36)
	_password_input.text_submitted.connect(func(_t): _on_auth_submit())
	vbox.add_child(_password_input)

	# Status label
	_status_label = Label.new()
	_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status_label.custom_minimum_size = Vector2(0, 36)
	vbox.add_child(_status_label)

	# Submit button
	_submit_button = Button.new()
	_submit_button.custom_minimum_size = Vector2(0, 40)
	_submit_button.add_theme_font_size_override("font_size", 16)
	_submit_button.pressed.connect(_on_auth_submit)
	vbox.add_child(_submit_button)

	# Toggle mode (login ↔ register)
	_toggle_mode_btn = Button.new()
	_toggle_mode_btn.flat = true
	_toggle_mode_btn.pressed.connect(_on_toggle_mode)
	vbox.add_child(_toggle_mode_btn)

	# Cancel
	var cancel_btn = Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(func(): _auth_popup.visible = false)
	vbox.add_child(cancel_btn)

	_set_mode(false)
