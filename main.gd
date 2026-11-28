extends Control

var surface_levels: Array[String] = [
	"res://levels/stage_01/surface_01.tscn",
	"res://levels/stage_02/surface_02.tscn"
]
var underground_levels: Array[String] = [
	"res://levels/stage_01/underground_01.tscn",
	"res://levels/stage_02/underground_02.tscn"
]

# Musik per stage (urutan sama dengan daftar level). Kalau stage lebih banyak
# daripada daftar ini, lagu terakhir dipakai. Kosongkan daftar kalau tidak ada musik.
const ALLEN_MUSIC: Array[String] = [
	"res://assets/audio/stage_allen1.mp3",
]
const LUNA_MUSIC: Array[String] = [
	"res://assets/audio/stage_luna1.mp3",
]
const ALLEN_VOLUME_DB := 4.0   # musik stage Allen (makin mendekati 0 makin keras)
const LUNA_VOLUME_DB := -10 # musik stage Luna

@onready var top_container: SubViewportContainer = $TopContainer
@onready var bottom_container: SubViewportContainer = $BottomContainer
@onready var top_viewport: SubViewport = $TopContainer/TopViewport
@onready var bottom_viewport: SubViewport = $BottomContainer/BottomViewport
@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_screen: GameOverScreen = $GameOverScreen

var fade_rect: ColorRect
var is_switching: bool = false

func _ready() -> void:
	get_tree().paused = false
	GameBridge.is_game_over = false
	GameBridge.stage_changed.connect(_load_stage)
	GameBridge.signal_state_changed.connect(_on_signal_state_changed)
	GameBridge.game_over.connect(_on_game_over)
	GameBridge.game_won.connect(_on_game_won)

	pause_menu.resume_requested.connect(_on_pause_resume)
	pause_menu.restart_requested.connect(_on_retry_or_restart)
	pause_menu.main_menu_requested.connect(_on_go_main_menu)
	game_over_screen.retry_requested.connect(_on_retry_or_restart)
	game_over_screen.main_menu_requested.connect(_on_go_main_menu)

	_create_fade_rect()
	_show_top_screen()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_switching and not game_over_screen.visible and not pause_menu.visible:
		get_tree().paused = true
		pause_menu.open_pause()
		Game.play_sfx("select")
		get_viewport().set_input_as_handled()

func _on_pause_resume() -> void:
	get_tree().paused = false

func _on_retry_or_restart() -> void:
	get_tree().paused = false
	GameBridge.reset_state()
	Game.go_to(Game.SCENE_GAME)

func _on_go_main_menu() -> void:
	get_tree().paused = false
	GameBridge.reset_state()
	Game.go_to(Game.SCENE_MAIN_MENU)

func _on_game_over() -> void:
	if pause_menu.visible:
		pause_menu.close_pause()
	Game.stop_music(0.5)
	get_tree().paused = true
	game_over_screen.show_screen()

# ------------------------
# TRANSISI (kotak hitam dibuat lewat kode)
# ------------------------
func _create_fade_rect() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	add_child(layer)

	fade_rect = ColorRect.new()
	fade_rect.color = Color.BLACK
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.modulate.a = 0.0
	layer.add_child(fade_rect)

# ------------------------
# MUSIK
# ------------------------
func _play_stage_music(list: Array[String], volume_db: float) -> void:
	if list.is_empty():
		return
	var path := list[mini(GameBridge.current_stage, list.size() - 1)]
	Game.play_music(path, volume_db)

func _on_game_won() -> void:
	Game.stop_music(1.2)
	Game.go_to(Game.SCENE_OUTRO)

# ------------------------
# TAMPILAN LAYAR
# ------------------------
func _show_top_screen() -> void:
	top_container.visible = true
	bottom_container.visible = false
	_set_level_active(top_viewport, true)
	_set_level_active(bottom_viewport, false)   # Luna dibekukan sampai giliran dia
	GameBridge.active_screen = GameBridge.Screen.TOP
	GameBridge.screen_switched.emit(GameBridge.active_screen)
	_play_stage_music(ALLEN_MUSIC, ALLEN_VOLUME_DB)   # musik stage Allen         # musik stage Allen

func _show_bottom_screen() -> void:
	top_container.visible = false
	bottom_container.visible = true
	_set_level_active(bottom_viewport, true)
	_set_level_active(top_viewport, false)
	GameBridge.active_screen = GameBridge.Screen.BOTTOM
	GameBridge.screen_switched.emit(GameBridge.active_screen)
	_play_stage_music(LUNA_MUSIC, LUNA_VOLUME_DB)     # musik stage Luna            # musik stage Luna

func _set_level_active(viewport: SubViewport, active: bool) -> void:
	if viewport.get_child_count() == 0:
		return
	viewport.get_child(0).process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

# ------------------------
# STAGE
# ------------------------
func _load_stage(index: int) -> void:
	if index < 0 or index >= surface_levels.size() or index >= underground_levels.size():
		push_warning("Indeks stage tidak valid: %d" % index)
		return

	is_switching = false
	_clear_viewport(top_viewport)
	_clear_viewport(bottom_viewport)

	var new_top_scene: Node2D = (load(surface_levels[index]) as PackedScene).instantiate() as Node2D
	var new_bottom_scene: Node2D = (load(underground_levels[index]) as PackedScene).instantiate() as Node2D

	top_viewport.add_child(new_top_scene)
	bottom_viewport.add_child(new_bottom_scene)

	# Stage baru selalu dimulai dari layar Allen (musik Allen ikut dimulai)
	_show_top_screen()

func _clear_viewport(viewport: SubViewport) -> void:
	for child: Node in viewport.get_children():
		viewport.remove_child(child)
		child.queue_free()

# ------------------------
# PINDAH KE LUNA
# ------------------------
func _on_signal_state_changed(is_active: bool) -> void:
	# completed_stage() juga memancarkan sinyal ini dengan nilai false
	if is_active:
		switch_to_underground()

func switch_to_underground() -> void:
	if is_switching:
		return
	is_switching = true

	Game.stop_music(0.8)   # musik Allen memudar bersamaan dengan layar menghitam

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.8)   # layar jadi hitam
	tween.tween_callback(_show_bottom_screen)                 # tukar layar (musik Luna mulai)
	tween.tween_interval(0.6)                                 # jeda layar kosong
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8)   # layar terang lagi
	tween.tween_callback(func(): is_switching = false)
