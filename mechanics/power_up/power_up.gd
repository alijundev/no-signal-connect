class_name PowerUp
extends Area2D

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

enum BuffType {
	HEAL,
	ENERGY_BOOST,
	SHIELD,
	DAMAGE_BOOST,
}

@export var buff_type: BuffType = BuffType.HEAL
@export var random_type: bool = false
@export var allow_damage_boost: bool = true
@export var duration: float = 8.0
@export var heal_amount: float = 35.0

@onready var box_bg: ColorRect = $BoxBg
@onready var border_rect: ColorRect = $BorderRect
@onready var icon_label: Label = $IconLabel

var _base_y: float = 0.0
var _time: float = 0.0
var _collected: bool = false

func _ready() -> void:
	if random_type:
		var pool: Array[BuffType] = [BuffType.HEAL, BuffType.ENERGY_BOOST, BuffType.SHIELD]
		if allow_damage_boost:
			pool.append(BuffType.DAMAGE_BOOST)
		buff_type = pool[randi() % pool.size()]

	_base_y = position.y
	_apply_visual()
	body_entered.connect(_on_body_entered)

func pop_up() -> void:
	var start_y: float = position.y
	var tw: Tween = create_tween()
	tw.tween_property(self, "position:y", start_y - 34.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func() -> void:
		_base_y = position.y
	)

func _process(delta: float) -> void:
	_time += delta
	position.y = _base_y + sin(_time * 4.0) * 4.0

func _apply_visual() -> void:
	var col: Color = Color("#4cd964")
	var txt: String = "+HP"
	match buff_type:
		BuffType.HEAL:
			col = Color("#4cd964")
			txt = "+HP"
		BuffType.ENERGY_BOOST:
			col = RetroTheme.COL_CYAN
			txt = "NRG"
		BuffType.SHIELD:
			col = Color("#5b6ee1")
			txt = "SHD"
		BuffType.DAMAGE_BOOST:
			col = RetroTheme.COL_ACCENT
			txt = "ATK"

	border_rect.color = col
	box_bg.color = Color("#182028")
	icon_label.text = txt
	var font: Font = RetroTheme.load_font()
	if font != null:
		icon_label.add_theme_font_override("font", font)
	icon_label.add_theme_font_size_override("font_size", 8)
	icon_label.add_theme_color_override("font_color", col)

func _on_body_entered(body: Node2D) -> void:
	if _collected:
		return
	if body is BasePlayer:
		_collected = true
		(body as BasePlayer).apply_buff(int(buff_type), duration, heal_amount)
		Game.play_sfx("select", 1.25)
		queue_free.call_deferred()
