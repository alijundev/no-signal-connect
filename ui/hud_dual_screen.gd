extends CanvasLayer

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@onready var top_hud: Control = $TopHUD
@onready var bottom_hud: Control = $BottomHUD
@onready var top_title_label: Label = $TopHUD/VBoxContainer/TopTitle
@onready var bottom_title_label: Label = $BottomHUD/VBoxContainer/BottomTitle
@onready var top_hp_bar: ProgressBar = $TopHUD/VBoxContainer/TopHPBar
@onready var top_energy_bar: ProgressBar = $TopHUD/VBoxContainer/TopEnergyBar
@onready var bottom_hp_bar: ProgressBar = $BottomHUD/VBoxContainer/BottomHPBar
@onready var bottom_energy_bar: ProgressBar = $BottomHUD/VBoxContainer/BottomEnergyBar

var _top_buff_label: Label
var _bottom_buff_label: Label

func _ready() -> void:
	_apply_hud_style()
	_build_buff_labels()
	GameBridge.player_health_updated.connect(_on_health_updated)
	GameBridge.player_energy_updated.connect(_on_energy_updated)
	GameBridge.player_buff_updated.connect(_on_buff_updated)
	GameBridge.signal_state_changed.connect(_refresh)
	GameBridge.screen_switched.connect(_refresh)
	_refresh()

func _build_buff_labels() -> void:
	var font: Font = RetroTheme.load_font()
	_top_buff_label = _create_buff_label(font)
	$TopHUD/VBoxContainer.add_child(_top_buff_label)
	_bottom_buff_label = _create_buff_label(font)
	$BottomHUD/VBoxContainer.add_child(_bottom_buff_label)

func _create_buff_label(font: Font) -> Label:
	var lbl := Label.new()
	lbl.visible = false
	if font != null:
		lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", 9)
	lbl.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	lbl.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	lbl.add_theme_constant_override("outline_size", 3)
	return lbl

func _on_buff_updated(screen: GameBridge.Screen, buff_text: String) -> void:
	var lbl: Label = _top_buff_label if screen == GameBridge.Screen.TOP else _bottom_buff_label
	if lbl == null:
		return
	lbl.visible = buff_text != ""
	lbl.text = "BUFF: " + buff_text if buff_text != "" else ""

func _apply_hud_style() -> void:
	var font: Font = RetroTheme.load_font()
	var labels: Array[Label] = [top_title_label, bottom_title_label]
	for lbl: Label in labels:
		if font != null:
			lbl.add_theme_font_override("font", font)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
		lbl.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
		lbl.add_theme_constant_override("outline_size", 3)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	var bg_box: StyleBoxFlat = RetroTheme.box(Color(RetroTheme.COL_BG, 0.85), RetroTheme.COL_OUTLINE, 2, 0, 0)
	var hp_fill: StyleBoxFlat = RetroTheme.box(Color("#4cd964"), RetroTheme.COL_OUTLINE, 2, 0, 0)
	var energy_fill: StyleBoxFlat = RetroTheme.box(RetroTheme.COL_CYAN, RetroTheme.COL_OUTLINE, 2, 0, 0)

	var hp_bars: Array[ProgressBar] = [top_hp_bar, bottom_hp_bar]
	for hp_bar: ProgressBar in hp_bars:
		hp_bar.add_theme_stylebox_override("background", bg_box)
		hp_bar.add_theme_stylebox_override("fill", hp_fill)
	var energy_bars: Array[ProgressBar] = [top_energy_bar, bottom_energy_bar]
	for en_bar: ProgressBar in energy_bars:
		en_bar.add_theme_stylebox_override("background", bg_box)
		en_bar.add_theme_stylebox_override("fill", energy_fill)

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
