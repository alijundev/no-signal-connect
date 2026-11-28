extends CanvasLayer

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@onready var status_card: PanelContainer = $StatusCard
@onready var character_label: Label = $StatusCard/VBoxContainer/HeaderRow/CharacterLabel
@onready var signal_label: Label = $StatusCard/VBoxContainer/HeaderRow/SignalLabel
@onready var hp_tag: Label = $StatusCard/VBoxContainer/HPRow/HPTag
@onready var hp_bar: ProgressBar = $StatusCard/VBoxContainer/HPRow/HPBar
@onready var hp_value: Label = $StatusCard/VBoxContainer/HPRow/HPBar/HPValue
@onready var energy_tag: Label = $StatusCard/VBoxContainer/EnergyRow/EnergyTag
@onready var energy_bar: ProgressBar = $StatusCard/VBoxContainer/EnergyRow/EnergyBar
@onready var energy_value: Label = $StatusCard/VBoxContainer/EnergyRow/EnergyBar/EnergyValue
@onready var buff_label: Label = $StatusCard/VBoxContainer/BuffLabel

@onready var stage_chip: PanelContainer = $StageChip
@onready var stage_label: Label = $StageChip/VBoxContainer/StageLabel
@onready var pause_hint_label: Label = $StageChip/VBoxContainer/PauseHintLabel

var _health_cache: Dictionary = {}
var _energy_cache: Dictionary = {}
var _buff_cache: Dictionary = {}
var _hp_fill_style: StyleBoxFlat
var _energy_fill_style: StyleBoxFlat

func _ready() -> void:
	_apply_hud_style()
	GameBridge.player_health_updated.connect(_on_health_updated)
	GameBridge.player_energy_updated.connect(_on_energy_updated)
	GameBridge.player_buff_updated.connect(_on_buff_updated)
	GameBridge.signal_state_changed.connect(_refresh)
	GameBridge.screen_switched.connect(_refresh)
	GameBridge.stage_changed.connect(_refresh)
	_refresh()

func _apply_hud_style() -> void:
	var font: Font = RetroTheme.load_font()

	var text_labels: Array[Label] = [
		character_label, signal_label, hp_tag, hp_value,
		energy_tag, energy_value, buff_label, stage_label, pause_hint_label
	]
	for lbl: Label in text_labels:
		if font != null:
			lbl.add_theme_font_override("font", font)
		lbl.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
		lbl.add_theme_constant_override("outline_size", 3)

	character_label.add_theme_font_size_override("font_size", 12)
	signal_label.add_theme_font_size_override("font_size", 9)
	hp_tag.add_theme_font_size_override("font_size", 9)
	hp_tag.add_theme_color_override("font_color", Color("#76ff7a"))
	hp_value.add_theme_font_size_override("font_size", 8)
	hp_value.add_theme_color_override("font_color", RetroTheme.COL_TEXT)

	energy_tag.add_theme_font_size_override("font_size", 9)
	energy_tag.add_theme_color_override("font_color", RetroTheme.COL_CYAN)
	energy_value.add_theme_font_size_override("font_size", 8)
	energy_value.add_theme_color_override("font_color", RetroTheme.COL_TEXT)

	buff_label.add_theme_font_size_override("font_size", 8)
	buff_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)

	stage_label.add_theme_font_size_override("font_size", 10)
	stage_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	pause_hint_label.add_theme_font_size_override("font_size", 8)
	pause_hint_label.add_theme_color_override("font_color", RetroTheme.COL_TEXT_IDLE)

	var bg_box: StyleBoxFlat = RetroTheme.box(Color(RetroTheme.COL_BG, 0.9), RetroTheme.COL_OUTLINE, 2, 0, 0)
	_hp_fill_style = RetroTheme.box(Color("#4cd964"), RetroTheme.COL_OUTLINE, 2, 0, 0)
	_energy_fill_style = RetroTheme.box(RetroTheme.COL_CYAN, RetroTheme.COL_OUTLINE, 2, 0, 0)

	hp_bar.add_theme_stylebox_override("background", bg_box)
	hp_bar.add_theme_stylebox_override("fill", _hp_fill_style)
	energy_bar.add_theme_stylebox_override("background", bg_box)
	energy_bar.add_theme_stylebox_override("fill", _energy_fill_style)

	stage_chip.add_theme_stylebox_override("panel", RetroTheme.box(Color(RetroTheme.COL_PANEL, 0.88), RetroTheme.COL_EXTRUDE, 2, 12, 8))

func _on_health_updated(screen: GameBridge.Screen, current: float, max_val: float) -> void:
	_health_cache[screen] = Vector2(current, max_val)
	if screen == GameBridge.active_screen:
		_sync_health_bar(current, max_val)

func _on_energy_updated(screen: GameBridge.Screen, current: float, max_val: float) -> void:
	_energy_cache[screen] = Vector2(current, max_val)
	if screen == GameBridge.active_screen:
		_sync_energy_bar(current, max_val)

func _on_buff_updated(screen: GameBridge.Screen, buff_text: String) -> void:
	_buff_cache[screen] = buff_text
	if screen == GameBridge.active_screen:
		_sync_buff_label(buff_text)

func _sync_health_bar(current: float, max_val: float) -> void:
	hp_bar.max_value = max_val
	hp_bar.value = current
	hp_value.text = "%d/%d" % [ceili(current), roundi(max_val)]

	var ratio: float = current / maxf(max_val, 1.0)
	if ratio >= 0.5:
		_hp_fill_style.bg_color = Color("#4cd964")
	elif ratio >= 0.25:
		_hp_fill_style.bg_color = RetroTheme.COL_ACCENT
	else:
		_hp_fill_style.bg_color = RetroTheme.COL_ALLEN

func _sync_energy_bar(current: float, max_val: float) -> void:
	energy_bar.max_value = max_val
	energy_bar.value = current
	var pct: int = roundi((current / maxf(max_val, 1.0)) * 100.0)
	energy_value.text = "%d%%" % pct

func _sync_buff_label(buff_text: String) -> void:
	buff_label.visible = buff_text != ""
	buff_label.text = "BUFF: " + buff_text if buff_text != "" else ""

func _refresh(_unused: Variant = null) -> void:
	var screen: GameBridge.Screen = GameBridge.active_screen
	var is_top: bool = screen == GameBridge.Screen.TOP
	var accent: Color = RetroTheme.COL_ALLEN if is_top else RetroTheme.COL_LUNA

	status_card.add_theme_stylebox_override("panel", RetroTheme.box(Color(RetroTheme.COL_PANEL, 0.92), accent, 3, 12, 10))
	character_label.text = "ALLEN" if is_top else "LUNA"
	character_label.add_theme_color_override("font_color", accent)

	var signal_on: bool = GameBridge.is_signal_active
	signal_label.text = "SIGNAL: ON" if signal_on else "SIGNAL: OFF"
	signal_label.add_theme_color_override("font_color", Color("#76ff7a") if signal_on else Color("#ff7b7b"))

	stage_label.text = "STAGE %d/%d" % [GameBridge.current_stage + 1, GameBridge.total_stages]

	var hp_data: Vector2 = _health_cache.get(screen, Vector2(100.0, 100.0)) as Vector2
	_sync_health_bar(hp_data.x, hp_data.y)

	var en_data: Vector2 = _energy_cache.get(screen, Vector2(100.0, 100.0)) as Vector2
	_sync_energy_bar(en_data.x, en_data.y)

	var buff_text: String = str(_buff_cache.get(screen, ""))
	_sync_buff_label(buff_text)
