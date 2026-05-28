extends Node
# Supabase REST API client.

const SUPABASE_URL      := "https://sdogpbddeaevheqennbe.supabase.co"
const SUPABASE_ANON_KEY := "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkb2dwYmRkZWFldmhlcWVubmJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1NTAyMDAsImV4cCI6MjA5MjEyNjIwMH0.fjo7zfbBeFqrEVH9zqSsncxpNoTIcqW4NtKZNT4UWeE"

var _auth: Node

func _ready():
	_auth = get_node_or_null("/root/AuthManager")

# ── Auth ──────────────────────────────────────────────────────────────────────

func login(email: String, password: String) -> Dictionary:
	var body = JSON.stringify({"email": email, "password": password})
	var url  = "%s/auth/v1/token?grant_type=password" % SUPABASE_URL
	var res  = await _post(url, body, false)
	if res.has("access_token"):
		await _ensure_profile(res["access_token"], res.get("refresh_token", ""), res["user"]["id"])
	return res

func register(email: String, password: String, username: String) -> Dictionary:
	var body = JSON.stringify({"email": email, "password": password})
	var url  = "%s/auth/v1/signup" % SUPABASE_URL
	var res  = await _post(url, body, false)
	if res.has("access_token"):
		await _create_profile(res["access_token"], res.get("refresh_token", ""), res["user"]["id"], username)
	return res

func logout() -> void:
	await _post("%s/auth/v1/logout" % SUPABASE_URL, "", true)

# ── Profiles ──────────────────────────────────────────────────────────────────

func get_profile(user_id: String) -> Dictionary:
	var res = await _fetch("%s/rest/v1/profiles?id=eq.%s&select=*" % [SUPABASE_URL, user_id], true)
	return res if res is Dictionary else {}

func _create_profile(token: String, refresh_token: String, user_id: String, username: String) -> void:
	var body = JSON.stringify({"id": user_id, "username": username})
	await _post_with_token("%s/rest/v1/profiles" % SUPABASE_URL, body, token)
	_auth.set_session(token, refresh_token, user_id, username)

func _ensure_profile(token: String, refresh_token: String, user_id: String) -> void:
	var url = "%s/rest/v1/profiles?id=eq.%s&select=username" % [SUPABASE_URL, user_id]
	var res = await _fetch_with_token(url, token)
	var username = ""
	if res is Array and res.size() > 0:
		username = res[0].get("username", "")
	_auth.set_session(token, refresh_token, user_id, username)

# ── Solutions ─────────────────────────────────────────────────────────────────

func submit_solution(level_id: String, code: String, move_count: int, code_length: int) -> Dictionary:
	if not _auth.is_logged_in():
		return {"error": "not_logged_in"}
	var body = JSON.stringify({
		"user_id":     _auth.get_user_id(),
		"level_id":    level_id,
		"code":        code,
		"move_count":  move_count,
		"code_length": code_length
	})
	return await _post("%s/rest/v1/solutions" % SUPABASE_URL, body, true,
			{"Prefer": "resolution=merge-duplicates"})

func get_leaderboard(level_id: String, limit: int = 10) -> Array:
	var url = "%s/rest/v1/solutions?level_id=eq.%s&select=move_count,code_length,profiles(username)&order=move_count.asc,code_length.asc&limit=%d" % [SUPABASE_URL, level_id, limit]
	var res = await _fetch(url, true)
	return res if res is Array else []

func get_my_solution(level_id: String) -> Dictionary:
	if not _auth.is_logged_in():
		return {}
	var url = "%s/rest/v1/solutions?level_id=eq.%s&user_id=eq.%s&select=*" % [SUPABASE_URL, level_id, _auth.get_user_id()]
	var res = await _fetch(url, true)
	return res[0] if (res is Array and res.size() > 0) else {}

# ── Levels ────────────────────────────────────────────────────────────────────

func upload_level(level_data: Dictionary) -> Dictionary:
	if not _auth.is_logged_in():
		return {"error": "not_logged_in"}
	# Map editor dict format → DB column names
	var db_payload := {
		"author_id":    _auth.get_user_id(),
		"name":         level_data.get("level_name", "Untitled"),
		"grid_data":    {"layout": level_data.get("layout", "")},
		"hint_text":    level_data.get("hint_text", ""),
		"starter_code": level_data.get("starter_code", ""),
		"description":  level_data.get("description", ""),
		"is_official":  false,
		"is_published": true,
	}
	return await _post("%s/rest/v1/levels" % SUPABASE_URL,
			JSON.stringify(db_payload), true, {"Prefer": "return=representation"})

func get_community_levels(page: int = 0, per_page: int = 20) -> Array:
	var res = await get_community_levels_raw(page, per_page)
	if not res is Array:
		push_error("[API] get_community_levels unexpected response: %s" % JSON.stringify(res))
	return res if res is Array else []

# Raw version — returns exactly what the API sends back (Array or error Dict).
func get_community_levels_raw(page: int = 0, per_page: int = 20) -> Variant:
	var offset = page * per_page
	var url = "%s/rest/v1/levels?is_published=eq.true&select=id,name,description,avg_rating,solve_count,play_count,profiles!author_id(username)&order=solve_count.desc&limit=%d&offset=%d" % [SUPABASE_URL, per_page, offset]
	return await _fetch(url, false)

func get_level(level_id: String) -> Dictionary:
	var url = "%s/rest/v1/levels?id=eq.%s&select=*,profiles!author_id(username)" % [SUPABASE_URL, level_id]
	var res = await _fetch(url, false)
	if res is Array and res.size() > 0:
		return _db_to_game(res[0])
	return {}

# Converts a raw DB row into the dict format the game scenes expect.
func _db_to_game(d: Dictionary) -> Dictionary:
	var gd = d.get("grid_data", {})
	var layout := ""
	if gd is Dictionary:
		layout = gd.get("layout", "")
	var profiles = d.get("profiles", null)
	var author := "Unknown"
	if profiles is Dictionary:
		author = profiles.get("username", "Unknown")
	return {
		"level_id":     d.get("id", ""),
		"level_name":   d.get("name", "Untitled"),
		"layout":       layout,
		"hint_text":    d.get("hint_text", ""),
		"starter_code": d.get("starter_code", ""),
		"author":       author,
		"solve_count":  d.get("solve_count", 0),
		"play_count":   d.get("play_count", 0),
	}

# ── HTTP core — fresh HTTPRequest per call, no shared state ──────────────────

func _fetch(url: String, authenticated: bool) -> Variant:
	return await _request(url, HTTPClient.METHOD_GET, _base_headers(authenticated), "")

func _fetch_with_token(url: String, token: String) -> Variant:
	return await _request(url, HTTPClient.METHOD_GET, _token_headers(token), "")

func _post(url: String, body: String, authenticated: bool, extra: Dictionary = {}) -> Dictionary:
	var headers = _base_headers(authenticated)
	for key in extra:
		headers.append("%s: %s" % [key, extra[key]])
	var res = await _request(url, HTTPClient.METHOD_POST, headers, body)
	return res if res is Dictionary else {}

func _post_with_token(url: String, body: String, token: String) -> Dictionary:
	var res = await _request(url, HTTPClient.METHOD_POST, _token_headers(token), body)
	return res if res is Dictionary else {}

func _request(url: String, method: int, headers: PackedStringArray, body: String,
		_is_retry: bool = false) -> Variant:
	# Each call gets its own HTTPRequest node so there is no shared mutable state.
	var http := HTTPRequest.new()
	add_child(http)
	# HTML5 builds: the browser already decompresses gzip responses, so Godot
	# must not try to decompress them again (causes stream_peer_gzip FAILED
	# and a garbled body that fails to parse as JSON).
	http.accept_gzip = false

	var err = http.request(url, headers, method, body)
	if err != OK:
		http.queue_free()
		push_error("HTTPRequest failed to start: error %d" % err)
		return {"error": "request_failed", "msg": "Could not send request (error %d)" % err}

	var data = await http.request_completed
	http.queue_free()

	var http_code  : int             = data[1]
	if http_code == 0:
		push_error("[API] network error or timeout (code 0) for: %s" % url)
		return {"error": "network_error", "msg": "Network error — check your connection"}
	var body_bytes : PackedByteArray = data[3]
	var body_text  : String          = body_bytes.get_string_from_utf8()

	print("[API] %s  →  %d" % [url, http_code])

	var parsed = JSON.parse_string(body_text)

	# Auto-refresh expired token and retry once
	if http_code == 401 and not _is_retry:
		var refreshed = await _refresh_session()
		if refreshed:
			var new_headers = _replace_auth_header(headers)
			return await _request(url, method, new_headers, body, true)
		return {"error": "http_401", "msg": "Session expired. Please log in again."}

	if http_code >= 400:
		var api_msg := ""
		if parsed is Dictionary:
			api_msg = parsed.get("msg", parsed.get("message", body_text))
		else:
			api_msg = body_text
		push_error("[API] error %d: %s" % [http_code, api_msg])
		return {"error": "http_%d" % http_code, "msg": api_msg}

	return parsed if parsed != null else {}

func _refresh_session() -> bool:
	if not _auth or _auth.get_refresh_token() == "":
		_auth.clear_session()
		return false

	var body = JSON.stringify({"refresh_token": _auth.get_refresh_token()})
	var url  = "%s/auth/v1/token?grant_type=refresh_token" % SUPABASE_URL
	var headers = PackedStringArray([
		"Content-Type: application/json",
		"apikey: %s" % SUPABASE_ANON_KEY,
	])

	var http := HTTPRequest.new()
	add_child(http)
	http.accept_gzip = false
	http.request(url, headers, HTTPClient.METHOD_POST, body)
	var data = await http.request_completed
	http.queue_free()

	var http_code : int    = data[1]
	var body_text : String = data[3].get_string_from_utf8()
	var parsed             = JSON.parse_string(body_text)

	if http_code == 200 and parsed is Dictionary and parsed.has("access_token"):
		var new_refresh = parsed.get("refresh_token", _auth.get_refresh_token())
		_auth.set_session(parsed["access_token"], new_refresh,
				_auth.get_user_id(), _auth.get_username())
		print("[API] token refreshed successfully")
		return true

	print("[API] token refresh failed — logging out")
	_auth.clear_session()
	return false

func _replace_auth_header(headers: PackedStringArray) -> PackedStringArray:
	var result := PackedStringArray()
	for h in headers:
		if h.begins_with("Authorization:"):
			result.append("Authorization: Bearer %s" % _auth.get_token())
		else:
			result.append(h)
	return result

# ── Header helpers ────────────────────────────────────────────────────────────

func _base_headers(authenticated: bool) -> PackedStringArray:
	var h := PackedStringArray([
		"Content-Type: application/json",
		"apikey: %s" % SUPABASE_ANON_KEY,
	])
	if authenticated and _auth and _auth.is_logged_in():
		h.append("Authorization: Bearer %s" % _auth.get_token())
	else:
		h.append("Authorization: Bearer %s" % SUPABASE_ANON_KEY)
	return h

func _token_headers(token: String) -> PackedStringArray:
	return PackedStringArray([
		"Content-Type: application/json",
		"apikey: %s" % SUPABASE_ANON_KEY,
		"Authorization: Bearer %s" % token,
	])
