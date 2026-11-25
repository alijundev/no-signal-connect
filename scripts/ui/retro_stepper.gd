class_name RetroStepper
extends RetroButton
## Baris pengaturan ala retro: "LABEL ........ < NILAI >".
## Kiri/kanan mengganti nilai; klik / Enter memajukan nilai (berputar).

signal value_changed(index: int)

@export var options := PackedStringArray()
@export var index := 0:
	set(value):
		index = posmod(value, maxi(options.size(), 1))
		queue_redraw()


func _ready() -> void:
	super()
	press_sfx = ""
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	pressed.connect(step.bind(1))


func step(direction: int) -> void:
	if options.is_empty():
		return
	index += direction
	Game.play_sfx("move", 1.25)
	value_changed.emit(index)


func _gui_input(event: InputEvent) -> void:
	if not has_focus():
		return
	if event.is_action_pressed("ui_left"):
		step(-1)
		accept_event()
	elif event.is_action_pressed("ui_right"):
		step(1)
		accept_event()


func _draw() -> void:
	super()
	if options.is_empty():
		return
	var font := get_theme_font("font")
	var font_size := get_theme_font_size("font_size")
	var value := "< %s >" % options[index]
	var width := font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var pos := Vector2(
		floorf(size.x - 20.0 - width),
		floorf((size.y - font.get_height(font_size)) * 0.5 + font.get_ascent(font_size)))
	var color := get_theme_color("font_focus_color") if has_focus() else get_theme_color("font_color")
	if has_focus():
		color = Pal.COL_ACCENT
	draw_string(font, pos + Vector2(2, 2), value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Pal.COL_SHADOW)
	draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
