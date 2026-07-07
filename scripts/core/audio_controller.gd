extends Node
## Global audio manager (autoload). Plays one persistent background-music loop
## that survives scene changes, and owns a master mute toggle — persisted to the
## shared settings file and exposed as a small speaker button drawn above every
## scene. Muting hits the Master bus, so it silences the music *and* SFX (e.g.
## the level-complete jingle) with a single control.

const _SETTINGS_PATH := "user://ledibug_settings.cfg"
const _MUSIC_PATH     := "res://assets/audio/background_music.wav"

var _music: AudioStreamPlayer
var _muted := false
var _button: Button
var _canvas: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # keep audio + toggle alive even if paused
	_muted = _load_muted()
	_apply_mute()
	_start_music()
	_build_toggle()

# ── Public API ────────────────────────────────────────────────────────────────

func is_muted() -> bool:
	return _muted

func toggle_muted() -> void:
	set_muted(not _muted)

func set_muted(m: bool) -> void:
	_muted = m
	_apply_mute()
	_save_muted()
	_refresh_toggle()

# ── Music ─────────────────────────────────────────────────────────────────────

func _start_music() -> void:
	var stream = load(_MUSIC_PATH)
	if stream is AudioStreamWAV:
		# Loop natively so repeats are gapless.
		stream.loop_mode  = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end   = int(stream.get_length() * stream.mix_rate)
	_music = AudioStreamPlayer.new()
	_music.stream = stream
	_music.volume_db = -16.0  # background level — present but unobtrusive
	add_child(_music)
	_music.play()

# ── Mute ──────────────────────────────────────────────────────────────────────

func _apply_mute() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), _muted)

# ── Floating speaker toggle (shown in every scene) ─────────────────────────────

func _build_toggle() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 128  # above the game and all in-scene popups
	add_child(_canvas)

	_button = Button.new()
	_button.focus_mode = Control.FOCUS_NONE
	_button.custom_minimum_size = Vector2(36, 36)
	_button.add_theme_font_size_override("font_size", 18)
	var normal := _make_style(Color(0.09, 0.10, 0.14, 0.72))
	var hover  := _make_style(Color(0.16, 0.18, 0.24, 0.88))
	_button.add_theme_stylebox_override("normal",  normal)
	_button.add_theme_stylebox_override("hover",   hover)
	_button.add_theme_stylebox_override("pressed", hover)
	# Pin to the bottom-right corner of the viewport (the top-right holds the
	# user bar in the menu; the bottom-right is clear across scenes).
	_button.anchor_left   = 1.0
	_button.anchor_right  = 1.0
	_button.anchor_top    = 1.0
	_button.anchor_bottom = 1.0
	_button.offset_left   = -46.0
	_button.offset_right  = -10.0
	_button.offset_top    = -46.0
	_button.offset_bottom = -10.0
	_button.pressed.connect(toggle_muted)
	_canvas.add_child(_button)
	_refresh_toggle()

func _refresh_toggle() -> void:
	if _button:
		_button.text = "🔇" if _muted else "🔊"
		_button.tooltip_text = "Unmute sound" if _muted else "Mute sound"

func _make_style(bg: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(8)
	return s

# ── Persistence ───────────────────────────────────────────────────────────────

func _load_muted() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(_SETTINGS_PATH) != OK:
		return false
	return bool(cfg.get_value("audio", "muted", false))

func _save_muted() -> void:
	var cfg := ConfigFile.new()
	cfg.load(_SETTINGS_PATH)  # keep other settings (progress, tutorial flag)
	cfg.set_value("audio", "muted", _muted)
	cfg.save(_SETTINGS_PATH)
