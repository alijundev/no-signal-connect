extends Control

var surface_levels: Array[String] = [
	"res://levels/stage_01/surface_01.tscn",
	"res://levels/stage_02/surface_02.tscn"
]
var underground_levels: Array[String] = [
	"res://levels/stage_01/underground_01.tscn",
	"res://levels/stage_02/underground_02.tscn"
]

@onready var top_container: SubViewportContainer = $TopContainer
@onready var bottom_container: SubViewportContainer = $BottomContainer
@onready var top_viewport: SubViewport = $TopContainer/TopViewport
@onready var bottom_viewport: SubViewport = $BottomContainer/BottomViewport

var fade_rect: ColorRect
var is_switching: bool = false

func _ready() -> void:
	GameBridge.stage_changed.connect(_load_stage)
	GameBridge.signal_state_changed.connect(_on_signal_state_changed)

	_create_fade_rect()
	_show_top_screen()

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
# TAMPILAN LAYAR
# ------------------------
func _show_top_screen() -> void:
	top_container.visible = true
	bottom_container.visible = false
	_set_level_active(top_viewport, true)
	_set_level_active(bottom_viewport, false)   # Luna dibekukan sampai giliran dia
	GameBridge.active_screen = GameBridge.Screen.TOP
	GameBridge.screen_switched.emit(GameBridge.active_screen)

func _show_bottom_screen() -> void:
	top_container.visible = false
	bottom_container.visible = true
	_set_level_active(bottom_viewport, true)
	_set_level_active(top_viewport, false)
	GameBridge.active_screen = GameBridge.Screen.BOTTOM
	GameBridge.screen_switched.emit(GameBridge.active_screen)

func _set_level_active(viewport: SubViewport, active: bool) -> void:
	if viewport.get_child_count() == 0:
		return
	viewport.get_child(0).process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED

# ------------------------
# STAGE
# ------------------------
func _load_stage(index: int) -> void:
	if top_viewport.get_child_count() > 0:
		top_viewport.get_child(0).queue_free()

	if bottom_viewport.get_child_count() > 0:
		bottom_viewport.get_child(0).queue_free()

	var new_top_scene: Node2D = load(surface_levels[index]).instantiate()
	var new_bottom_scene: Node2D = load(underground_levels[index]).instantiate()

	top_viewport.add_child(new_top_scene)
	bottom_viewport.add_child(new_bottom_scene)

	# Stage baru selalu dimulai dari layar Allen
	_show_top_screen()

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

	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.8)   # layar jadi hitam
	tween.tween_callback(_show_bottom_screen)                 # tukar layar saat gelap
	tween.tween_interval(0.6)                                 # jeda layar kosong
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.8)   # layar terang lagi
	tween.tween_callback(func(): is_switching = false)
