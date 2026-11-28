extends Area2D

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@export var puzzle_scene: PackedScene

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D

var _active_puzzle: CanvasLayer = null
var is_activated: bool = false
var player_in_range: bool = false

func _ready() -> void:
	_setup_puzzle()
	_style_prompt_label()
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _setup_puzzle() -> void:
	var default_puzzle: CanvasLayer = get_node_or_null("CablePuzzle") as CanvasLayer
	if puzzle_scene != null:
		if default_puzzle != null:
			remove_child(default_puzzle)
			default_puzzle.queue_free()
		_active_puzzle = puzzle_scene.instantiate() as CanvasLayer
		add_child(_active_puzzle)
	else:
		_active_puzzle = default_puzzle

	if _active_puzzle != null and _active_puzzle.has_signal(&"puzzle_solved"):
		_active_puzzle.connect(&"puzzle_solved", activate_tower)

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
		if _active_puzzle != null and _active_puzzle.has_method(&"close_puzzle"):
			_active_puzzle.call(&"close_puzzle")

func activate_tower() -> void:
	is_activated = true
	prompt_label.visible = false
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(0.6, 1.0, 0.6), 0.4)
	GameBridge.set_signal_active(true)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_activated and GameBridge.active_screen == GameBridge.Screen.TOP and event.is_action_pressed("interact"):
		if _active_puzzle != null and not _active_puzzle.visible and _active_puzzle.has_method(&"open_puzzle"):
			_active_puzzle.call(&"open_puzzle")
			get_viewport().set_input_as_handled()
