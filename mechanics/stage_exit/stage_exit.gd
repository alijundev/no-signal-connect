class_name StageExit
extends Area2D

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@onready var warning_label: Label = $WarningLabel
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
@onready var placeholder_rect: ColorRect = get_node_or_null("ColorRect") as ColorRect

func _ready() -> void:
	_style_warning_label()
	warning_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	GameBridge.signal_state_changed.connect(_on_signal_state_changed)
	_update_visual(GameBridge.is_signal_active)

func _style_warning_label() -> void:
	var font: Font = RetroTheme.load_font()
	if font != null:
		warning_label.add_theme_font_override("font", font)
	warning_label.add_theme_font_size_override("font_size", 10)
	warning_label.add_theme_color_override("font_color", Color("#ff8a8a"))
	warning_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	warning_label.add_theme_constant_override("outline_size", 3)
	warning_label.add_theme_stylebox_override("normal", RetroTheme.box(Color(RetroTheme.COL_BG, 0.9), RetroTheme.COL_ALLEN, 2, 10, 6))
	warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning_label.reset_size()
	warning_label.position = Vector2(-warning_label.size.x * 0.5, -100.0)

func _on_signal_state_changed(is_active: bool) -> void:
	_update_visual(is_active)

func _update_visual(is_active: bool) -> void:
	if animated_sprite != null:
		animated_sprite.modulate = Color.WHITE if is_active else Color(0.4, 0.4, 0.4, 0.65)
		if animated_sprite.sprite_frames != null:
			if is_active and animated_sprite.sprite_frames.has_animation(&"open"):
				animated_sprite.play(&"open")
			elif not is_active and animated_sprite.sprite_frames.has_animation(&"locked"):
				animated_sprite.play(&"locked")
			elif animated_sprite.sprite_frames.has_animation(&"default"):
				animated_sprite.play(&"default")
	if placeholder_rect != null:
		placeholder_rect.color = Color(0.0, 1.0, 1.0, 1.0) if is_active else Color(0.35, 0.35, 0.35, 0.8)

func _on_body_entered(body: Node2D) -> void:
	if body is BasePlayer:
		if GameBridge.is_signal_active:
			GameBridge.completed_stage.call_deferred()
		else:
			warning_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is BasePlayer:
		warning_label.visible = false
