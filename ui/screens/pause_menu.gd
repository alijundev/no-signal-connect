class_name PauseMenu
extends CanvasLayer

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

signal resume_requested
signal restart_requested
signal main_menu_requested

@onready var root_control: Control = $Root
@onready var panel: PanelContainer = $Root/PanelContainer
@onready var title_label: Label = $Root/PanelContainer/VBoxContainer/TitleLabel
@onready var resume_button: Button = $Root/PanelContainer/VBoxContainer/Menu/ResumeButton
@onready var restart_button: Button = $Root/PanelContainer/VBoxContainer/Menu/RestartButton
@onready var menu_button: Button = $Root/PanelContainer/VBoxContainer/Menu/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	visible = false
	_apply_style()
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _apply_style() -> void:
	root_control.theme = RetroTheme.build()
	var font: Font = RetroTheme.load_font()
	panel.add_theme_stylebox_override("panel", RetroTheme.box(Color(RetroTheme.COL_PANEL, 0.95), RetroTheme.COL_CYAN, 4, 36, 28))

	if font != null:
		title_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	title_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	title_label.add_theme_constant_override("outline_size", 4)

	var buttons: Array[Button] = [resume_button, restart_button, menu_button]
	for btn: Button in buttons:
		btn.custom_minimum_size = Vector2(240, 42)
		if font != null:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 14)

func open_pause() -> void:
	visible = true
	resume_button.grab_focus()

func close_pause() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		Game.play_sfx("back")
		_on_resume_pressed()
		get_viewport().set_input_as_handled()

func _on_resume_pressed() -> void:
	visible = false
	resume_requested.emit()

func _on_restart_pressed() -> void:
	visible = false
	restart_requested.emit()

func _on_menu_pressed() -> void:
	visible = false
	main_menu_requested.emit()
