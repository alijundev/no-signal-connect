class_name RandomChest
extends Area2D

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")
const POWER_UP_SCENE: PackedScene = preload("res://mechanics/power_up/power_up.tscn")
const PowerUpScript = preload("res://mechanics/power_up/power_up.gd")

@export_range(0.0, 1.0, 0.05) var drop_chance: float = 0.85

@onready var prompt_label: Label = $PromptLabel
@onready var lid_rect: ColorRect = $ChestLid

var _player_in_range: bool = false
var _is_opened: bool = false

func _ready() -> void:
	_style_prompt_label()
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _style_prompt_label() -> void:
	var font: Font = RetroTheme.load_font()
	if font != null:
		prompt_label.add_theme_font_override("font", font)
	prompt_label.add_theme_font_size_override("font_size", 9)
	prompt_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	prompt_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	prompt_label.add_theme_constant_override("outline_size", 3)
	prompt_label.add_theme_stylebox_override("normal", RetroTheme.box(Color(RetroTheme.COL_BG, 0.88), RetroTheme.COL_ACCENT, 2, 8, 4))
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.reset_size()
	prompt_label.position = Vector2(-prompt_label.size.x * 0.5, -52.0)

func _on_body_entered(body: Node2D) -> void:
	if body is BasePlayer and not _is_opened:
		_player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D) -> void:
	if body is BasePlayer:
		_player_in_range = false
		prompt_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and not _is_opened and GameBridge.active_screen == GameBridge.Screen.TOP and event.is_action_pressed("interact"):
		_open_chest()
		get_viewport().set_input_as_handled()

func _open_chest() -> void:
	_is_opened = true
	prompt_label.visible = false
	if lid_rect != null:
		lid_rect.position.y -= 6.0
		lid_rect.color = lid_rect.color.darkened(0.35)

	if randf() <= drop_chance:
		Game.play_sfx("select", 1.1)
		var item: PowerUpScript = POWER_UP_SCENE.instantiate() as PowerUpScript
		item.random_type = true
		item.allow_damage_boost = false
		item.global_position = global_position + Vector2(0.0, -16.0)
		get_parent().add_child.call_deferred(item)
		item.call_deferred("pop_up")
	else:
		Game.play_sfx("back")
		_show_empty_text()

func _show_empty_text() -> void:
	prompt_label.text = "Kosong!"
	prompt_label.add_theme_color_override("font_color", RetroTheme.COL_DIM)
	prompt_label.reset_size()
	prompt_label.position = Vector2(-prompt_label.size.x * 0.5, -52.0)
	prompt_label.visible = true
	var tw: Tween = create_tween()
	tw.tween_interval(0.9)
	tw.tween_callback(func() -> void:
		prompt_label.visible = false
	)
