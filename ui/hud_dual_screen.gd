extends CanvasLayer

@onready var top_title_label: Label = $TopHUD/VBoxContainer/TopTitle
@onready var bottom_title_label: Label = $BottomHUD/VBoxContainer/BottomTitle
@onready var top_hp_bar: ProgressBar = $TopHUD/VBoxContainer/TopHPBar
@onready var top_energy_bar: ProgressBar = $TopHUD/VBoxContainer/TopEnergyBar
@onready var bottom_hp_bar: ProgressBar = $BottomHUD/VBoxContainer/BottomHPBar
@onready var bottom_energy_bar: ProgressBar = $BottomHUD/VBoxContainer/BottomEnergyBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameBridge.player_health_updated.connect(_on_health_updated)
	GameBridge.player_energy_updated.connect(_on_energy_updated)
	
	GameBridge.signal_state_changed.connect(_refresh_label)
	GameBridge.screen_switched.connect(_refresh_label)
	_refresh_label()
	
func _on_health_updated(screen: GameBridge.Screen, current: float, max_val: float):
	if screen == GameBridge.Screen.TOP:
		top_hp_bar.max_value = max_val
		top_hp_bar.value = current
	else:
		bottom_hp_bar.max_value = max_val
		bottom_hp_bar.value = current

func _on_energy_updated(screen: GameBridge.Screen, current: float, max_val: float):
	if screen == GameBridge.Screen.TOP:
		top_energy_bar.max_value = max_val
		top_energy_bar.value = current
	else:
		bottom_energy_bar.max_value = max_val
		bottom_energy_bar.value = current

func _refresh_label(_unused: Variant = null):
	if GameBridge.active_screen == GameBridge.Screen.TOP:
		top_title_label.text = "ALLEN [ACTIVE]"
		bottom_title_label.text = "LUNA [STANDBY]"
	else:
		top_title_label.text = "ALLEN [STANDBY]"
		bottom_title_label.text = "LUNA [ACTIVE]"

	var signal_status: String = "AKTIF" if GameBridge.is_signal_active else "MATI"
	bottom_title_label.text += " | SINYAL: " + signal_status
