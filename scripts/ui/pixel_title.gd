class_name PixelTitle
extends Control
## Judul pixel: huruf 3D (extrude) + outline tegas, warna huruf berputar
## seperti palette-cycling konsol lama, dan naik-turun 2px secara bertahap.

const Pal = preload("res://scripts/ui/retro_theme.gd")

@export var text := "BETWEEN US":
	set(value):
		text = value
		queue_redraw()
@export var font_size := 32
@export var extrude := 4
@export var outline := 2
@export var cycle_speed := 5.0 ## langkah ganti warna per detik
@export var bob_height := 2
@export var palette := PackedColorArray([
	Color("#ffffff"), Color("#a8f0ff"), Color("#c9b3ff"), Color("#ffb3dc"),
])

## Jumlah huruf yang tampil (-1 = semua). Dipakai efek mengetik di intro.
var visible_chars := -1:
	set(value):
		visible_chars = value
		queue_redraw()

var _last_step := -1
var _last_bob := 99
var _bob := 0
var _step := 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func reveal(duration := 0.8) -> void:
	visible_chars = 0
	var tw := create_tween()
	tw.tween_property(self, "visible_chars", text.length(), duration)
	tw.tween_callback(func(): visible_chars = -1)


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	_step = int(t * cycle_speed)
	_bob = roundi(sin(t * 2.2)) * bob_height
	if _step != _last_step or _bob != _last_bob:
		_last_step = _step
		_last_bob = _bob
		queue_redraw()


func _draw() -> void:
	var font := get_theme_default_font()
	if font == null:
		font = ThemeDB.fallback_font
	var count := text.length() if visible_chars < 0 else mini(visible_chars, text.length())
	if count <= 0:
		return

	# Posisi tiap huruf (selalu dihitung dari teks penuh supaya tidak bergeser saat mengetik)
	var xs: Array[float] = []
	var total := 0.0
	for i in text.length():
		xs.append(total)
		total += font.get_string_size(text[i], HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var x0 := floorf((size.x - total) * 0.5)
	var baseline := floorf((size.y - extrude - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)) + _bob

	for i in count:
		var ch := text[i]
		if ch == " ":
			continue
		var p := Vector2(x0 + xs[i], baseline)

		# 1) pinggiran gelap di sekeliling ujung extrude
		_outline(font, p + Vector2(extrude, extrude), ch)
		# 2) lapisan extrude (kedalaman 3D)
		for e in range(extrude, 0, -1):
			draw_string(font, p + Vector2(e, e), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Pal.COL_EXTRUDE)
		# 3) outline huruf depan
		_outline(font, p, ch)
		# 4) isi huruf, warna berputar per huruf
		var color := palette[(i + _step) % palette.size()]
		draw_string(font, p, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _outline(font: Font, p: Vector2, ch: String) -> void:
	for dx in [-outline, 0, outline]:
		for dy in [-outline, 0, outline]:
			if dx == 0 and dy == 0:
				continue
			draw_string(font, p + Vector2(dx, dy), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Pal.COL_OUTLINE)
