extends CanvasLayer

signal puzzle_solved

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

var current_step: int = 1
var total_step: int = 4

@onready var panel: PanelContainer = $PanelContainer
@onready var status_label: Label = $PanelContainer/VBoxContainer/StatusLabel
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

@onready var port1: Button = $PanelContainer/VBoxContainer/ButtonRow/Port1
@onready var port2: Button = $PanelContainer/VBoxContainer/ButtonRow/Port2
@onready var port3: Button = $PanelContainer/VBoxContainer/ButtonRow/Port3
@onready var port4: Button = $PanelContainer/VBoxContainer/ButtonRow/Port4

func _ready() -> void:
	visible = false
	_apply_retro_style()
	port1.pressed.connect(_on_port_pressed.bind(1, port1))
	port2.pressed.connect(_on_port_pressed.bind(2, port2))
	port3.pressed.connect(_on_port_pressed.bind(3, port3))
	port4.pressed.connect(_on_port_pressed.bind(4, port4))
	close_button.pressed.connect(close_puzzle)

func _apply_retro_style() -> void:
	var font: Font = RetroTheme.load_font()
	panel.add_theme_stylebox_override("panel", RetroTheme.box(RetroTheme.COL_PANEL, RetroTheme.COL_CYAN, 3, 24, 20))

	if font != null:
		status_label.add_theme_font_override("font", font)
	status_label.add_theme_font_size_override("font_size", 12)
	status_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	status_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	status_label.add_theme_constant_override("outline_size", 2)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var btn_normal: StyleBoxTexture = RetroTheme.pill_style(RetroTheme.COL_EXTRUDE)
	var btn_hover: StyleBoxTexture = RetroTheme.pill_style(RetroTheme.COL_PRIMARY)
	var btn_pressed: StyleBoxTexture = RetroTheme.pill_style(RetroTheme.COL_ALLEN)
	var btn_disabled: StyleBoxTexture = RetroTheme.pill_style(Color("#2e8b57"))

	var all_buttons: Array[Button] = [port1, port2, port3, port4, close_button]
	for btn: Button in all_buttons:
		if font != null:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
		btn.add_theme_color_override("font_hover_color", RetroTheme.COL_ACCENT)
		btn.add_theme_color_override("font_disabled_color", RetroTheme.COL_TEXT)
		btn.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
		btn.add_theme_constant_override("outline_size", 2)
		btn.add_theme_stylebox_override("normal", btn_normal)
		btn.add_theme_stylebox_override("hover", btn_hover)
		btn.add_theme_stylebox_override("pressed", btn_pressed)
		btn.add_theme_stylebox_override("disabled", btn_disabled)
		btn.custom_minimum_size = Vector2(104, 38)

func _on_port_pressed(port: int, ref: Button) -> void:
	if port == current_step:
		ref.disabled = true
		ref.modulate = Color(0.75, 1.0, 0.75)
		current_step += 1
		status_label.add_theme_color_override("font_color", Color("#76ff7a"))
		status_label.text = "Port %d Connected! (%d/%d)" % [port, current_step - 1, total_step]
		if current_step > total_step:
			puzzle_solved.emit()
			visible = false
	else:
		reset_puzzle()
		status_label.add_theme_color_override("font_color", Color("#ff6b6b"))
		status_label.text = "Wrong order! Start: 1 -> 2 -> 3 -> 4"

func reset_puzzle() -> void:
	current_step = 1
	var ports_button: Array[Button] = [port1, port2, port3, port4]
	for port: Button in ports_button:
		port.disabled = false
		port.modulate = Color.WHITE
	status_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	status_label.text = "Connect Ports: 1 -> 2 -> 3 -> 4"

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func open_puzzle() -> void:
	reset_puzzle()
	visible = true

func close_puzzle() -> void:
	visible = false
