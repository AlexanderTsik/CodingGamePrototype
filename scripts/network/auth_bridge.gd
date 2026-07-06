extends Node
## Single-sign-on bridge between the web platform (parent page) and the game
## (this iframe). Only active on the HTML5/Web export — a no-op everywhere else.
##
## The platform stores its Supabase session in cookies; the game stores its own
## in localStorage. They never see each other's storage, so without this bridge
## logging into one leaves the other logged out. We reconcile them over
## window.postMessage:
##
##   parent → game : { type: "ledibug:auth", payload: {access_token, refresh_token,
##                                                      user_id, username} | {event:"logout"} }
##   game → parent : same shape, sent whenever the game's own login/logout fires.
##
## On boot the game posts { type: "ledibug:ready" } so the parent knows to push
## its current session down (the parent is the source of truth at load time).

var _recv_cb                 # JavaScriptObject wrapping our GDScript callback — must stay referenced
var _applying_remote := false  # guard: don't echo a parent-pushed session back to the parent

func _ready() -> void:
	if OS.get_name() != "Web":
		return  # standalone/desktop build — nothing to bridge

	# Expose a function the page can call to hand us a session.
	_recv_cb = JavaScriptBridge.create_callback(_on_host_message)
	var window = JavaScriptBridge.get_interface("window")
	window.ledibugReceiveAuth = _recv_cb

	# Install the parent→game listener and announce we're ready to receive.
	JavaScriptBridge.eval("""
		(function(){
			if (window.__ledibugBridgeInstalled) return;
			window.__ledibugBridgeInstalled = true;
			window.addEventListener('message', function(e){
				var d = e.data;
				if (d && d.type === 'ledibug:auth' && typeof window.ledibugReceiveAuth === 'function') {
					try { window.ledibugReceiveAuth(JSON.stringify(d.payload || {})); } catch (err) {}
				}
			});
			if (window.parent && window.parent !== window) {
				window.parent.postMessage({ type: 'ledibug:ready' }, '*');
			}
		})();
	""", true)

	# Forward the game's own login / logout up to the platform.
	AuthManager.logged_in.connect(_on_local_login)
	AuthManager.logged_out.connect(_on_local_logout)

# ── Parent → game ───────────────────────────────────────────────────────────────

func _on_host_message(args) -> void:
	var json_str := str(args[0]) if (args is Array and args.size() > 0) else ""
	var data = JSON.parse_string(json_str)
	if not (data is Dictionary):
		return

	var is_logout: bool = data.get("event", "") == "logout" or str(data.get("access_token", "")) == ""
	var token := str(data.get("access_token", ""))

	# Ignore no-op pushes so we don't churn the UI or loop back to the parent.
	if is_logout and not AuthManager.is_logged_in():
		return
	if not is_logout and AuthManager.is_logged_in() and token == AuthManager.get_token():
		return

	_applying_remote = true
	if is_logout:
		AuthManager.clear_session()
	else:
		AuthManager.set_session(
			token,
			str(data.get("refresh_token", "")),
			str(data.get("user_id", "")),
			str(data.get("username", "")))
	_applying_remote = false

# ── Game → parent ───────────────────────────────────────────────────────────────

func _on_local_login(_username: String) -> void:
	if _applying_remote:
		return  # this login came *from* the parent — don't bounce it back
	_post_to_parent({
		"access_token":  AuthManager.get_token(),
		"refresh_token": AuthManager.get_refresh_token(),
		"user_id":       AuthManager.get_user_id(),
		"username":      AuthManager.get_username(),
	})

func _on_local_logout() -> void:
	if _applying_remote:
		return
	_post_to_parent({"event": "logout"})

func _post_to_parent(payload: Dictionary) -> void:
	# base64 the JSON so tokens can't break out of the eval'd string literal.
	var b64 := Marshalls.utf8_to_base64(JSON.stringify(payload))
	JavaScriptBridge.eval("""
		(function(){
			if (window.parent && window.parent !== window) {
				try {
					var p = JSON.parse(atob('%s'));
					window.parent.postMessage({ type: 'ledibug:auth', payload: p }, '*');
				} catch (e) {}
			}
		})();
	""" % b64, true)
