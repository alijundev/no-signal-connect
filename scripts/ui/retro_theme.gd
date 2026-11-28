extends RefCounted
## Tema retro-modern dibangun lewat kode (tanpa file .tres) supaya mudah diubah.
## Dipakai lewat: const RetroTheme = preload("res://scripts/ui/retro_theme.gd")
## Palet warna juga diakses komponen lain, mis. RetroTheme.COL_ACCENT.
##
## Press Start 2P dirancang pada grid 8px: pakai ukuran 8 / 16 / 24 / 32
## supaya setiap "pixel" huruf jatuh tepat di grid layar.

const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"

const COL_BG := Color("#1c1c1c")
const COL_PANEL := Color("#2c3438")
const COL_TEXT := Color("#ffffff")
const COL_TEXT_IDLE := Color("#cbdbfc")
const COL_DIM := Color("#c78c91")
const COL_ACCENT := Color("#fbf236")
const COL_PRIMARY := Color("#5b6ee1")
const COL_CYAN := Color("#4eb9d0")
const COL_PINK := Color("#ff98bc")
const COL_SHADOW := Color("#2a1e23")
const COL_EXTRUDE := Color("#1e6371")
const COL_OUTLINE := Color("#1c1c1c")

# Warna karakter
const COL_ALLEN := Color("#ba323e")   # merah rambut Allen
const COL_LUNA := Color("#4eb9d0")    # cyan mata Luna

# Tombol pil pixel (digambar lewat kode, warna dari palet tema)
const PILL_W := 28
const PILL_H := 17
const PILL_R := 8.0
const PILL_UNIT := 2   # 1 "pixel seni" = 2 pixel layar menu


static func load_font() -> Font:
	if not ResourceLoader.exists(FONT_PATH):
		push_warning("Font pixel tidak ditemukan di %s" % FONT_PATH)
		return null
	var font: Font = load(FONT_PATH)
	if font is FontFile:
		var ff := font as FontFile
		ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
		ff.hinting = TextServer.HINTING_NONE
		ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	return font


static func build() -> Theme:
	var t := Theme.new()
	var font := load_font()
	if font:
		t.default_font = font
	t.default_font_size = 16
	_build_button(t)
	_build_labels(t)
	_build_text_edit(t)
	return t


static func box(bg: Color, border: Color, border_w := 2, margin_h := 20, margin_v := 6) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(0) # sudut kotak tegas
	sb.anti_aliasing = false    # tepi tajam
	sb.content_margin_left = margin_h
	sb.content_margin_right = margin_h
	sb.content_margin_top = margin_v
	sb.content_margin_bottom = margin_v
	return sb


static func _in_round(x: int, y: int, w: float, h: float, r: float, ox: float, oy: float) -> bool:
	var px := x + 0.5 - ox
	var py := y + 0.5 - oy
	if px < 0.0 or py < 0.0 or px > w or py > h:
		return false
	var cx := clampf(px, r, w - r)
	var cy := clampf(py, r, h - r)
	return (px - cx) * (px - cx) + (py - cy) * (py - cy) <= r * r


static func pill_style(fill: Color, outline: Color = COL_OUTLINE) -> StyleBoxTexture:
	var hi := fill.lightened(0.38)   # garis terang di atas
	var sh := fill.darkened(0.32)    # bayangan di bawah
	var img := Image.create_empty(PILL_W, PILL_H, false, Image.FORMAT_RGBA8)
	for y in PILL_H:
		for x in PILL_W:
			if not _in_round(x, y, PILL_W, PILL_H, PILL_R, 0.0, 0.0):
				continue
			if not _in_round(x, y, PILL_W - 2, PILL_H - 2, PILL_R - 1.0, 1.0, 1.0):
				img.set_pixel(x, y, outline)
				continue
			var c := fill
			if y == 1:
				c = hi
			elif y >= PILL_H - 3:
				c = sh
			img.set_pixel(x, y, c)
	img.resize(PILL_W * PILL_UNIT, PILL_H * PILL_UNIT, Image.INTERPOLATE_NEAREST)

	var sb := StyleBoxTexture.new()
	sb.texture = ImageTexture.create_from_image(img)
	var m := PILL_R * PILL_UNIT
	sb.texture_margin_left = m
	sb.texture_margin_right = m
	sb.texture_margin_top = m
	sb.texture_margin_bottom = m
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 4
	sb.content_margin_bottom = 5
	return sb


static func _build_button(t: Theme) -> void:
	var idle := pill_style(COL_EXTRUDE)                 # teal Luna, kondisi biasa
	var lit := pill_style(COL_ALLEN)                    # merah Allen, item terpilih
	var off := pill_style(COL_DIM.darkened(0.45))       # nonaktif

	# Hover sengaja SAMA dengan normal: yang menyala hanya item yang fokus,
	# jadi tidak pernah ada dua item menyala bersamaan.
	t.set_stylebox("normal", "Button", idle)
	t.set_stylebox("hover", "Button", idle)
	t.set_stylebox("disabled", "Button", off)
	t.set_stylebox("pressed", "Button", lit)
	t.set_stylebox("hover_pressed", "Button", lit)
	t.set_stylebox("focus", "Button", lit)

	t.set_font_size("font_size", "Button", 16)
	t.set_color("font_color", "Button", COL_TEXT)
	t.set_color("font_hover_color", "Button", COL_TEXT)
	t.set_color("font_focus_color", "Button", COL_TEXT)
	t.set_color("font_pressed_color", "Button", COL_TEXT)
	t.set_color("font_hover_pressed_color", "Button", COL_TEXT)
	t.set_color("font_disabled_color", "Button", COL_DIM)
	# Teks putih dengan kontur gelap
	t.set_color("font_outline_color", "Button", COL_OUTLINE)
	t.set_constant("outline_size", "Button", 2)
	t.set_constant("shadow_offset_x", "Button", 0)
	t.set_constant("shadow_offset_y", "Button", 0)


static func _build_labels(t: Theme) -> void:
	t.set_font_size("font_size", "Label", 16)
	t.set_color("font_color", "Label", COL_TEXT)
	t.set_color("font_shadow_color", "Label", COL_SHADOW)
	t.set_constant("shadow_offset_x", "Label", 2)
	t.set_constant("shadow_offset_y", "Label", 2)
	t.set_constant("line_spacing", "Label", 4)

	_variation(t, "HeaderLabel", 24, COL_TEXT, COL_EXTRUDE, 3)
	_variation(t, "SectionLabel", 8, COL_ACCENT, COL_OUTLINE, 1)
	_variation(t, "BodyLabel", 8, COL_TEXT, COL_OUTLINE, 1)
	_variation(t, "HintLabel", 8, COL_DIM, COL_OUTLINE, 1)


static func _variation(t: Theme, type_name: String, size: int, color: Color, shadow: Color, shadow_px: int) -> void:
	t.set_type_variation(type_name, "Label")
	t.set_font_size("font_size", type_name, size)
	t.set_color("font_color", type_name, color)
	t.set_color("font_shadow_color", type_name, shadow)
	t.set_constant("shadow_offset_x", type_name, shadow_px)
	t.set_constant("shadow_offset_y", type_name, shadow_px)


static func _build_text_edit(t: Theme) -> void:
	t.set_stylebox("normal", "TextEdit", box(COL_PANEL, COL_DIM, 2, 8, 8))
	t.set_stylebox("focus", "TextEdit", box(COL_PANEL, COL_ACCENT, 2, 8, 8))
	t.set_stylebox("read_only", "TextEdit", box(COL_PANEL, COL_DIM, 2, 8, 8))
	t.set_font_size("font_size", "TextEdit", 8)
	t.set_color("font_color", "TextEdit", COL_TEXT)
	t.set_color("font_placeholder_color", "TextEdit", COL_DIM)
	t.set_color("caret_color", "TextEdit", COL_ACCENT)
	t.set_color("selection_color", "TextEdit", Color(COL_PRIMARY, 0.55))
	t.set_constant("line_spacing", "TextEdit", 4)
	t.set_constant("caret_width", "TextEdit", 2)
