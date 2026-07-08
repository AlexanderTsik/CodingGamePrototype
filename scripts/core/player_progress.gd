class_name PlayerProgress
## Persisted player progress — the highest built-in level the player has unlocked.
## Shared by the main menu ("Play" continues from here), the level select screen
## (locks not-yet-reached levels), and the game controller (records completion).
##
## Progress is namespaced by the signed-in account, so switching users on the
## same browser doesn't leak one player's unlocked levels to another — a new
## user starts from level 1. Guests share a single "guest" bucket. This is local
## to the current browser/device (it is not synced across devices).

const _PATH := "user://ledibug_settings.cfg"

static func _progress_key() -> String:
	"""Per-account settings key. Falls back to a shared guest bucket when nobody
	is signed in. UUID dashes are stripped so the key is a plain identifier."""
	var uid := ""
	var auth = Engine.get_main_loop().root.get_node_or_null("/root/AuthManager")
	if auth and auth.is_logged_in():
		uid = str(auth.get_user_id())
	if uid == "":
		return "unlocked_guest"
	return "unlocked_" + uid.replace("-", "")

static func highest_unlocked() -> int:
	"""Highest level the player may play (>= 1). Solving level N unlocks N+1."""
	var cfg := ConfigFile.new()
	if cfg.load(_PATH) != OK:
		return 1
	return maxi(1, int(cfg.get_value("progress", _progress_key(), 1)))

static func is_unlocked(level_id: int) -> bool:
	"""A level is playable once it's been reached (the previous one was solved)."""
	return level_id <= highest_unlocked()

static func is_solved(level_id: int) -> bool:
	"""Solving N unlocks N+1, so every level below the highest-unlocked is solved."""
	return level_id < highest_unlocked()

static func mark_solved(level_id: int) -> void:
	"""Record that `level_id` is solved, unlocking the next level. Never regresses."""
	if level_id + 1 <= highest_unlocked():
		return  # already at or beyond this — nothing to update
	var cfg := ConfigFile.new()
	cfg.load(_PATH)  # keep other settings (e.g. the tutorial flag, other users)
	cfg.set_value("progress", _progress_key(), level_id + 1)
	cfg.save(_PATH)
