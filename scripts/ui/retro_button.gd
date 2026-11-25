class_name RetroButton
extends Button
## Tombol menu retro.
## - Hover mouse memindahkan pilihan (focus), jadi hanya SATU item yang menyala.
## - Item terpilih diberi kotak outline (dari tema) + panah pixel berkedip di kiri-kanan.
## - Memainkan suara "move" saat pilihan berpindah dan suara press_sfx saat ditekan.

const Pal = preload("res://scripts/ui/retro_theme.gd")
const ARROW_PX := 2
const ARROW_HEIGHTS := [7, 5, 3, 1]

## Nama suara saat ditekan ("" = tanpa suara). Lihat Game.SFX_NAMES.
@export var press_sfx := "select"

var _time := 0.0
var _bob := 0


func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	set_process(false)
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	pressed.connect(_on_pressed)


func _process(delta: float) -> void:
	_time += delta
	var bob := int(_time / 0.35) % 2
	if bob != _bob:
		_bob = bob
		queue_redraw()


func _draw() -> void:
	if not has_focus() or disabled:
		return
	var cy := floorf(size.y * 0.5)
	var nudge := _bob * ARROW_PX
	_draw_arrow(Vector2(6.0 + nudge, cy), 1.0)
	_draw_arrow(Vector2(size.x - 6.0 - nudge, cy), -1.0)


## Segitiga pixel 4 kolom (tinggi 7/5/3/1 pixel), menunjuk ke arah `direction`.
func _draw_arrow(origin: Vector2, direction: float) -> void:
	for i in ARROW_HEIGHTS.size():
		var h: float = ARROW_HEIGHTS[i] * ARROW_PX
		var x := origin.x + direction * i * ARROW_PX
		if direction < 0.0:
			x -= ARROW_PX
		draw_rect(Rect2(x, origin.y - h * 0.5, ARROW_PX, h), Pal.COL_ACCENT)


func _on_mouse_entered() -> void:
	if not disabled and focus_mode != Control.FOCUS_NONE:
		grab_focus()


func _on_focus_entered() -> void:
	_time = 0.0
	_bob = 0
	set_process(true)
	queue_redraw()
	Game.play_sfx("move")


func _on_focus_exited() -> void:
	set_process(false)
	queue_redraw()


func _on_pressed() -> void:
	if press_sfx != "":
		Game.play_sfx(press_sfx)
