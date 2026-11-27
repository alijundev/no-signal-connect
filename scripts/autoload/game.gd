extends Node
## Autoload "Game": pengaturan, tema retro, overlay CRT, transisi scene, dan SFX.
## Dipanggil dari mana saja, mis. Game.go_to(Game.SCENE_SETTINGS).

signal settings_changed

const SCENE_MAIN_MENU := "res://scenes/main_menu.tscn"
const SCENE_GAME := "res://main.tscn"
const SCENE_INTRO := "res://scenes/intro.tscn"
const SCENE_SETTINGS := "res://scenes/settings.tscn"
const SCENE_FEEDBACK := "res://scenes/feedback.tscn"
const SCENE_CREDITS := "res://scenes/credits.tscn"
const MENU_SIZE := Vector2i(640, 360)
const GAME_SIZE := Vector2i(1280, 720)
var _in_game := false

const SETTINGS_PATH := "user://settings.cfg"
const SFX_NAMES := ["move", "select", "back", "start"]
const SFX_VOICES := 4

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

var master_volume := 0.8
var fullscreen := false
var crt_enabled := true

var _crt_layer: CanvasLayer
var _fade_rect: ColorRect
var _fade_material: ShaderMaterial
var _busy := false
var _sfx := {}
var _players: Array[AudioStreamPlayer] = []
var _next_player := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_settings()
	_build_sfx()
	_build_crt()
	_build_transition()
	apply_settings()
	_apply_mode(SCENE_MAIN_MENU)
	_fade_in_on_start()

# ------------------------------------------------------------------ Settings

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	apply_settings()
	save_settings()


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	apply_settings()
	save_settings()


func set_crt_enabled(value: bool) -> void:
	crt_enabled = value
	apply_settings()
	save_settings()


func apply_settings() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(master_volume, 0.0001)))
	AudioServer.set_bus_mute(0, master_volume <= 0.001)

	var wanted := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	if DisplayServer.window_get_mode() != wanted:
		DisplayServer.window_set_mode(wanted)

	if _crt_layer:
		_crt_layer.visible = crt_enabled and not _in_game
	settings_changed.emit()


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "master_volume", master_volume)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.set_value("video", "crt_enabled", crt_enabled)
	cfg.save(SETTINGS_PATH)


func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	master_volume = clampf(float(cfg.get_value("audio", "master_volume", master_volume)), 0.0, 1.0)
	fullscreen = bool(cfg.get_value("video", "fullscreen", fullscreen))
	crt_enabled = bool(cfg.get_value("video", "crt_enabled", crt_enabled))


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F11:
		set_fullscreen(not fullscreen)
		get_viewport().set_input_as_handled()


# ----------------------------------------------------------------------- SFX

func _build_sfx() -> void:
	for sfx_name in SFX_NAMES:
		var path := "res://assets/audio/%s.wav" % sfx_name
		if ResourceLoader.exists(path):
			_sfx[sfx_name] = load(path)
	for i in SFX_VOICES:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)


func play_sfx(sfx_name: String, pitch := 1.0) -> void:
	var stream: AudioStream = _sfx.get(sfx_name)
	if stream == null or _players.is_empty():
		return
	var player := _players[_next_player]
	_next_player = (_next_player + 1) % _players.size()
	player.stream = stream
	player.pitch_scale = pitch
	player.play()


# --------------------------------------------------------------- CRT overlay

func _build_crt() -> void:
	_crt_layer = CanvasLayer.new()
	_crt_layer.layer = 100
	add_child(_crt_layer)

	var rect := ColorRect.new()
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://shaders/crt.gdshader")
	rect.material = mat
	_crt_layer.add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


# --------------------------------------------------------------- Transitions

func _build_transition() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 90 # di bawah CRT, jadi efek CRT ikut menutupi transisi
	add_child(layer)

	_fade_rect = ColorRect.new()
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_material = ShaderMaterial.new()
	_fade_material.shader = load("res://shaders/pixel_transition.gdshader")
	_fade_rect.material = _fade_material
	layer.add_child(_fade_rect)
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_rect.visible = false


func _run_fade(from: float, to: float, duration: float) -> void:
	_fade_material.set_shader_parameter("progress", from)
	_fade_rect.visible = true
	var tw := create_tween()
	tw.tween_property(_fade_material, "shader_parameter/progress", to, duration)
	await tw.finished
	if to <= 0.0:
		_fade_rect.visible = false


func _fade_in_on_start() -> void:
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _run_fade(1.0, 0.0, 0.5)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func go_to(path: String) -> void:
	if _busy:
		return
	_busy = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP # blokir klik saat transisi
	await _run_fade(0.0, 1.0, 0.35)
	_apply_mode(path)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	await _run_fade(1.0, 0.0, 0.35)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_busy = false


func quit_game() -> void:
	if _busy:
		return
	_busy = true
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _run_fade(0.0, 1.0, 0.35)
	get_tree().quit()

func _apply_mode(path: String) -> void:
	_in_game = (path == SCENE_GAME or path == SCENE_INTRO)
	var win := get_tree().root
	win.content_scale_size = GAME_SIZE if _in_game else MENU_SIZE
	win.theme = null if _in_game else RetroTheme.build()
	if _crt_layer:
		_crt_layer.visible = crt_enabled and not _in_game
