class_name RandomChest
extends Area2D

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")
const POWER_UP_SCENE: PackedScene = preload("res://mechanics/power_up/power_up.tscn")
const PowerUpScript = preload("res://mechanics/power_up/power_up.gd")

@export_group("Loot Chances")
@export_range(0.0, 1.0, 0.05) var drop_chance: float = 0.85        ## Peluang peti berisi loot (sisanya kosong)
@export_range(0.0, 100.0, 1.0) var heal_weight: float = 35.0       ## Bobot peluang +HP
@export_range(0.0, 100.0, 1.0) var energy_weight: float = 35.0     ## Bobot peluang Energy Boost
@export_range(0.0, 100.0, 1.0) var shield_weight: float = 30.0     ## Bobot peluang Shield
@export_range(0.0, 100.0, 1.0) var damage_boost_weight: float = 0.0 ## Bobot peluang ATK x2 (default 0 untuk Allen)

@export_group("Audio")
@export var buff_sound: AudioStream   ## Played when the chest drops a buff
@export var empty_sound: AudioStream  ## Played when the chest is empty
@export var sound_volume_db: float = 0.0

@onready var prompt_label: Label = $PromptLabel
@onready var lid_rect: ColorRect = $ChestLid

var _player_in_range: bool = false
var _is_opened: bool = false
var _sfx_player: AudioStreamPlayer

func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.volume_db = sound_volume_db
	add_child(_sfx_player)
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
		_play_chest_sound(buff_sound, "select", 1.1)
		var item: PowerUpScript = POWER_UP_SCENE.instantiate() as PowerUpScript
		item.random_type = false
		item.buff_type = _pick_buff_type()
		item.global_position = global_position + Vector2(0.0, -16.0)
		get_parent().add_child.call_deferred(item)
		item.call_deferred("pop_up")
	else:
		_play_chest_sound(empty_sound, "back", 1.0)
		_show_empty_text()

func _pick_buff_type() -> PowerUpScript.BuffType:
	var types: Array[PowerUpScript.BuffType] = [
		PowerUpScript.BuffType.HEAL,
		PowerUpScript.BuffType.ENERGY_BOOST,
		PowerUpScript.BuffType.SHIELD,
		PowerUpScript.BuffType.DAMAGE_BOOST,
	]
	var weights: Array[float] = [
		maxf(heal_weight, 0.0),
		maxf(energy_weight, 0.0),
		maxf(shield_weight, 0.0),
		maxf(damage_boost_weight, 0.0),
	]
	var total: float = 0.0
	for w: float in weights:
		total += w

	if total <= 0.0:
		return PowerUpScript.BuffType.HEAL

	var roll: float = randf() * total
	var acc: float = 0.0
	for i: int in types.size():
		acc += weights[i]
		if roll <= acc:
			return types[i]
	return PowerUpScript.BuffType.HEAL

func _play_chest_sound(custom_stream: AudioStream, fallback_sfx: String, pitch: float) -> void:
	if custom_stream != null and _sfx_player != null:
		_sfx_player.stream = custom_stream
		_sfx_player.volume_db = sound_volume_db
		_sfx_player.play()
	else:
		Game.play_sfx(fallback_sfx, pitch)

func _show_empty_text() -> void:
	prompt_label.text = "Empty!"
	prompt_label.add_theme_color_override("font_color", RetroTheme.COL_DIM)
	prompt_label.reset_size()
	prompt_label.position = Vector2(-prompt_label.size.x * 0.5, -52.0)
	prompt_label.visible = true
	var tw: Tween = create_tween()
	tw.tween_interval(0.9)
	tw.tween_callback(func() -> void:
		prompt_label.visible = false
	)
