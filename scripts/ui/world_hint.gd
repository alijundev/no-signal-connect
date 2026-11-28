class_name WorldHint
extends PanelContainer
## Panel petunjuk tutorial bergaya retro di dalam dunia permainan.

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@export_multiline var hint_text: String = ""
@export var accent_color: Color = RetroTheme.COL_ACCENT

var _label: Label


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = -1

	add_theme_stylebox_override(
		"panel",
		RetroTheme.box(Color(RetroTheme.COL_BG, 0.84), accent_color, 2, 10, 8)
	)

	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.text = hint_text

	var font: Font = RetroTheme.load_font()
	if font != null:
		_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
	_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	_label.add_theme_constant_override("outline_size", 3)
	_label.add_theme_constant_override("line_spacing", 5)

	add_child(_label)
	reset_size()
