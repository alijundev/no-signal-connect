extends CanvasLayer

@onready var top_hud: Control = $TopHUD
@onready var bottom_hud: Control = $BottomHUD
@onready var top_title_label: Label = $TopHUD/VBoxContainer/TopTitle
@onready var bottom_title_label: Label = $BottomHUD/VBoxContainer/BottomTitle
@onready var top_hp_bar: ProgressBar = $TopHUD/VBoxContainer/TopHPBar
@onready var top_energy_bar: ProgressBar = $TopHUD/VBoxContainer/TopEnergyBar
@onready var bottom_hp_bar: ProgressBar = $BottomHUD/VBoxContainer/BottomHPBar
@onready var bottom_energy_bar: ProgressBar = $BottomHUD/VBoxContainer/BottomEnergyBar

func _ready() -> void:
	GameBridge.player_health_updated.connect(_on_health_updated)
	GameBridge.player_energy_updated.connect(_on_energy_updated)
	GameBridge.signal_state_changed.connect(_refresh)
	GameBridge.screen_switched.connect(_refresh)
	_refresh()

func _on_health_updated(screen: GameBridge.Screen, current: float, max_val: float):
	var bar := top_hp_bar if screen == GameBridge.Screen.TOP else bottom_hp_bar
	bar.max_value = max_val
	bar.value = current

func _on_energy_updated(screen: GameBridge.Screen, current: float, max_val: float):
	var bar := top_energy_bar if screen == GameBridge.Screen.TOP else bottom_energy_bar
	bar.max_value = max_val
	bar.value = current

func _refresh(_unused: Variant = null) -> void:
	var is_top := GameBridge.active_screen == GameBridge.Screen.TOP
	top_hud.visible = is_top
	bottom_hud.visible = not is_top

	top_title_label.text = "ALLEN"
	var signal_status := "AKTIF" if GameBridge.is_signal_active else "MATI"
	bottom_title_label.text = "LUNA | SINYAL: " + signal_status
