extends Node

# Stores the current session in memory.
# On HTML5 we mirror to localStorage via JavaScriptBridge so it survives page refresh.

const STORAGE_KEY_TOKEN   := "ledibug_access_token"
const STORAGE_KEY_REFRESH := "ledibug_refresh_token"
const STORAGE_KEY_USER_ID := "ledibug_user_id"
const STORAGE_KEY_USERNAME := "ledibug_username"

var _access_token:  String = ""
var _refresh_token: String = ""
var _user_id:       String = ""
var _username:      String = ""

signal logged_in(username: String)
signal logged_out

func _ready():
	_load_from_storage()

# ── Public API ────────────────────────────────────────────────────────────────

func is_logged_in() -> bool:
	return _access_token != ""

func get_token() -> String:
	return _access_token

func get_refresh_token() -> String:
	return _refresh_token

func get_user_id() -> String:
	return _user_id

func get_username() -> String:
	return _username

func set_session(token: String, refresh_token: String, user_id: String, username: String):
	_access_token  = token
	_refresh_token = refresh_token
	_user_id       = user_id
	_username      = username
	_save_to_storage()
	logged_in.emit(username)

func clear_session():
	_access_token  = ""
	_refresh_token = ""
	_user_id       = ""
	_username      = ""
	_clear_storage()
	logged_out.emit()

# ── Storage helpers ───────────────────────────────────────────────────────────

func _save_to_storage():
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("localStorage.setItem('%s','%s')" % [STORAGE_KEY_TOKEN,   _access_token])
		JavaScriptBridge.eval("localStorage.setItem('%s','%s')" % [STORAGE_KEY_REFRESH, _refresh_token])
		JavaScriptBridge.eval("localStorage.setItem('%s','%s')" % [STORAGE_KEY_USER_ID, _user_id])
		JavaScriptBridge.eval("localStorage.setItem('%s','%s')" % [STORAGE_KEY_USERNAME,_username])
	else:
		var cfg = ConfigFile.new()
		cfg.set_value("session", "token",         _access_token)
		cfg.set_value("session", "refresh_token", _refresh_token)
		cfg.set_value("session", "user_id",       _user_id)
		cfg.set_value("session", "username",      _username)
		cfg.save("user://session.cfg")

func _load_from_storage():
	if OS.get_name() == "Web":
		_access_token  = _js_get(STORAGE_KEY_TOKEN)
		_refresh_token = _js_get(STORAGE_KEY_REFRESH)
		_user_id       = _js_get(STORAGE_KEY_USER_ID)
		_username      = _js_get(STORAGE_KEY_USERNAME)
	else:
		var cfg = ConfigFile.new()
		if cfg.load("user://session.cfg") == OK:
			_access_token  = cfg.get_value("session", "token",         "")
			_refresh_token = cfg.get_value("session", "refresh_token", "")
			_user_id       = cfg.get_value("session", "user_id",       "")
			_username      = cfg.get_value("session", "username",      "")

func _clear_storage():
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("localStorage.removeItem('%s')" % STORAGE_KEY_TOKEN)
		JavaScriptBridge.eval("localStorage.removeItem('%s')" % STORAGE_KEY_REFRESH)
		JavaScriptBridge.eval("localStorage.removeItem('%s')" % STORAGE_KEY_USER_ID)
		JavaScriptBridge.eval("localStorage.removeItem('%s')" % STORAGE_KEY_USERNAME)
	else:
		DirAccess.remove_absolute("user://session.cfg")

func _js_get(key: String) -> String:
	var result = JavaScriptBridge.eval("localStorage.getItem('%s') || ''" % key)
	return str(result) if result != null else ""
