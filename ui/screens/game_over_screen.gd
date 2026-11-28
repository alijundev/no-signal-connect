class_name GameOverScreen
extends CanvasLayer

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

signal retry_requested
signal main_menu_requested

@onready var root_control: Control = $Root
@onready var panel: PanelContainer = $Root/PanelContainer
@onready var title_label: Label = $Root/PanelContainer/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $Root/PanelContainer/VBoxContainer/SubtitleLabel
@onready var retry_button: Button = $Root/PanelContainer/VBoxContainer/Menu/RetryButton
@onready var menu_button: Button = $Root/PanelContainer/VBoxContainer/Menu/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	visible = false
	_apply_style()
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _apply_style() -> void:
	root_control.theme = RetroTheme.build()
	var font: Font = RetroTheme.load_font()
	panel.add_theme_stylebox_override("panel", RetroTheme.box(Color(RetroTheme.COL_PANEL, 0.95), RetroTheme.COL_ALLEN, 4, 36, 28))

	if font != null:
		title_label.add_theme_font_override("font", font)
		subtitle_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", RetroTheme.COL_ALLEN)
	title_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	title_label.add_theme_constant_override("outline_size", 4)

	subtitle_label.add_theme_font_size_override("font_size", 11)
	subtitle_label.add_theme_color_override("font_color", RetroTheme.COL_TEXT_IDLE)
	subtitle_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	subtitle_label.add_theme_constant_override("outline_size", 2)

	var buttons: Array[Button] = [retry_button, menu_button]
	for btn: Button in buttons:
		btn.custom_minimum_size = Vector2(240, 42)
		if font != null:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 14)

func show_screen() -> void:
	visible = true
	retry_button.grab_focus()

func _on_retry_pressed() -> void:
	visible = false
	retry_requested.emit()

func _on_menu_pressed() -> void:
	visible = false
	main_menu_requested.emit()
