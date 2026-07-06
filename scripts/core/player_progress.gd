class_name PlayerProgress
## Persisted player progress — the highest built-in level the player has unlocked.
## Shared by the main menu ("Play" continues from here), the level select screen
## (locks not-yet-reached levels), and the game controller (records completion).
## Stored in the shared settings file, alongside the tutorial flag.

const _PATH := "user://ledibug_settings.cfg"

static func highest_unlocked() -> int:
	"""Highest level the player may play (>= 1). Solving level N unlocks N+1."""
	var cfg := ConfigFile.new()
	if cfg.load(_PATH) != OK:
		return 1
	return maxi(1, int(cfg.get_value("progress", "highest_unlocked", 1)))

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
	cfg.load(_PATH)  # keep other settings (e.g. the tutorial flag)
	cfg.set_value("progress", "highest_unlocked", level_id + 1)
	cfg.save(_PATH)
