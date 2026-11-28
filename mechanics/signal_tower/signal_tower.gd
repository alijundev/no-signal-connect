extends Area2D

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D
@onready var cable_puzzle: CanvasLayer = $CablePuzzle

var is_activated: bool = false
var player_in_range: bool = false

func _ready() -> void:
	_style_prompt_label()
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	cable_puzzle.puzzle_solved.connect(activate_tower)

func _style_prompt_label() -> void:
	prompt_label.label_settings = null
	var font: Font = RetroTheme.load_font()
	if font != null:
		prompt_label.add_theme_font_override("font", font)
	prompt_label.add_theme_font_size_override("font_size", 10)
	prompt_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	prompt_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	prompt_label.add_theme_constant_override("outline_size", 3)
	prompt_label.add_theme_stylebox_override("normal", RetroTheme.box(Color(RetroTheme.COL_BG, 0.88), RetroTheme.COL_CYAN, 2, 10, 6))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.reset_size()
	prompt_label.position = Vector2(-prompt_label.size.x * 0.5, -110.0)

func _on_body_entered(body: Node2D) -> void:
	if body is BasePlayer and not is_activated:
		player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is BasePlayer:
		player_in_range = false
		prompt_label.visible = false
		cable_puzzle.close_puzzle()

func activate_tower() -> void:
	is_activated = true
	prompt_label.visible = false
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(0.6, 1.0, 0.6), 0.4)
	GameBridge.set_signal_active(true)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_activated and GameBridge.active_screen == GameBridge.Screen.TOP and event.is_action_pressed("interact"):
		cable_puzzle.open_puzzle()
