extends RefCounted
## Tema retro-modern dibangun lewat kode (tanpa file .tres) supaya mudah diubah.
## Dipakai lewat: const RetroTheme = preload("res://scripts/ui/retro_theme.gd")
## Palet warna juga diakses komponen lain, mis. RetroTheme.COL_ACCENT.
##
## Press Start 2P dirancang pada grid 8px: pakai ukuran 8 / 16 / 24 / 32
## supaya setiap "pixel" huruf jatuh tepat di grid layar.

const FONT_PATH := "res://assets/fonts/PressStart2P-Regular.ttf"

const COL_BG := Color("#050b08")
const COL_PANEL := Color("#0a1a12")
const COL_TEXT := Color("#d9ffe6")
const COL_TEXT_IDLE := Color("#4fd48a")
const COL_DIM := Color("#2f7a52")
const COL_ACCENT := Color("#ffb000")
const COL_PRIMARY := Color("#00ff9c")
const COL_CYAN := Color("#4de1ff")
const COL_PINK := Color("#ff5c5c")
const COL_SHADOW := Color("#04180d")
const COL_EXTRUDE := Color("#0b6b3a")
const COL_OUTLINE := Color("#02100a")


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


static func _build_button(t: Theme) -> void:
	var clear := Color(0, 0, 0, 0)
	var idle := box(clear, clear)
	# Hover sengaja SAMA dengan normal: yang menyala hanya item yang fokus,
	# jadi tidak pernah ada dua item menyala bersamaan.
	t.set_stylebox("normal", "Button", idle)
	t.set_stylebox("hover", "Button", idle)
	t.set_stylebox("disabled", "Button", idle)
	t.set_stylebox("pressed", "Button", box(Color(COL_ACCENT, 0.18), COL_ACCENT))
	t.set_stylebox("hover_pressed", "Button", box(Color(COL_ACCENT, 0.18), COL_ACCENT))
	t.set_stylebox("focus", "Button", box(Color(1, 1, 1, 0.07), COL_TEXT))

	t.set_font_size("font_size", "Button", 16)
	t.set_color("font_color", "Button", COL_TEXT_IDLE)
	t.set_color("font_hover_color", "Button", COL_TEXT_IDLE)
	t.set_color("font_focus_color", "Button", COL_TEXT)
	t.set_color("font_pressed_color", "Button", COL_ACCENT)
	t.set_color("font_hover_pressed_color", "Button", COL_ACCENT)
	t.set_color("font_disabled_color", "Button", COL_DIM)
	t.set_color("font_shadow_color", "Button", COL_SHADOW)
	t.set_constant("shadow_offset_x", "Button", 2)
	t.set_constant("shadow_offset_y", "Button", 2)
	t.set_constant("outline_size", "Button", 0)


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
