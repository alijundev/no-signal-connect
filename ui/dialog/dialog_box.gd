class_name DialogBox
extends CanvasLayer
## Kotak dialog memakai gambar buatan sendiri + teks Press Start 2P.
## Ukuran kotak, font, dan margin menyesuaikan lebar layar secara otomatis.
## Nama dan potret sudah ada di gambar, jadi cukup isi "text" dan "box".
## Contoh:
## dialog.show_dialog([
##     {"text": "Halo", "box": "res://assets/UI/dialog_allen.png"},
##     {"text": "Hai", "box": "res://assets/UI/dialog_luna.png"},
## ])

signal dialog_finished
signal line_started(index: int)

const Pal = preload("res://scripts/ui/retro_theme.gd")

@export_group("Kotak")
@export var box_texture: Texture2D                  ## gambar kotak bawaan
@export var trim_transparent_padding: bool = true   ## buang tepi transparan di PNG
@export var auto_scale: bool = true                 ## skala otomatis mengikuti lebar layar
@export_range(0.3, 1.0, 0.05) var screen_width_ratio: float = 0.75
@export var box_scale: float = 4.0                  ## dipakai kalau Auto Scale dimatikan
@export var bottom_margin: float = 24.0             ## jarak dari tepi bawah layar

@export_group("Area teks (PIXEL GAMBAR setelah dipotong, bukan pixel layar)")
@export var text_area_left: int = 36                ## lewati slot potret di kiri
@export var text_area_top: int = 8
@export var text_area_right: int = 6
@export var text_area_bottom: int = 4
@export var text_color: Color = Color("#2b1b3d")
@export var text_size: int = 0                      ## 0 = otomatis mengikuti skala
@export var chars_per_second: float = 20.0

var _built: bool = false
var _root: Control
var _panel: TextureRect
var _margin: MarginContainer
var _text_label: RichTextLabel
var _hint: Label

var _lines: Array = []
var _index: int = -1
var _typing: bool = false
var _active: bool = false
var _tween: Tween
var _font: Font
var _trim_cache: Dictionary = {}

func _ready() -> void:
	layer = 50
	_ensure_ui()
	_root.visible = false

func is_active() -> bool:
	return _active

# ------------------------
# PUBLIK
# ------------------------
func show_dialog(lines: Array) -> void:
	_ensure_ui()
	if lines.is_empty():
		dialog_finished.emit()
		return
	_lines = lines
	_index = -1
	_active = true
	_root.visible = true
	_next_line()

# ------------------------
# UI (dibuat lewat kode, hanya sekali)
# ------------------------
func _ensure_ui() -> void:
	if _built:
		return
	_built = true
	layer = 50
	_font = Pal.load_font()

	_root = Control.new()
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_panel = TextureRect.new()
	_panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_panel.stretch_mode = TextureRect.STRETCH_SCALE
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_root.add_child(_panel)

	_margin = MarginContainer.new()
	_panel.add_child(_margin)
	_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_text_label = RichTextLabel.new()
	_text_label.scroll_active = false
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if _font:
		_text_label.add_theme_font_override("normal_font", _font)
	_text_label.add_theme_color_override("default_color", text_color)
	_margin.add_child(_text_label)

	# Penanda ">>" di pojok kanan bawah, tidak memakan ruang teks
	_hint = Label.new()
	_hint.text = ">>"
	if _font:
		_hint.add_theme_font_override("font", _font)
	_hint.add_theme_color_override("font_color", text_color)
	_hint.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_hint.visible = false
	_panel.add_child(_hint)

	var blink := create_tween().set_loops()
	blink.tween_property(_hint, "modulate:a", 0.2, 0.4)
	blink.tween_property(_hint, "modulate:a", 1.0, 0.4)

	_apply_box(box_texture)
	_ignore_mouse(_root)

# Buang tepi transparan PNG (hasil di-cache supaya tidak dihitung ulang)
func _prepare_texture(tex: Texture2D) -> Texture2D:
	if tex == null or not trim_transparent_padding:
		return tex

	var key := tex.resource_path if tex.resource_path != "" else str(tex.get_instance_id())
	if _trim_cache.has(key):
		return _trim_cache[key]

	var result: Texture2D = tex
	var img := tex.get_image()
	if img != null:
		var used := img.get_used_rect()
		if used.size.x > 0 and used.size != Vector2i(tex.get_size()):
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(used)
			result = atlas
	_trim_cache[key] = result
	return result

# Skala kelipatan bulat supaya pixel art tetap tajam
func _current_scale(tex: Texture2D) -> float:
	if tex == null or not auto_scale:
		return box_scale
	var screen_w := get_viewport().get_visible_rect().size.x
	return maxf(1.0, floorf(screen_w * screen_width_ratio / float(tex.get_width())))

# Pasang gambar kotak (tengah bawah layar), lalu sesuaikan margin dan font
func _apply_box(source: Texture2D) -> void:
	if _panel == null:
		return
	var tex := _prepare_texture(source)
	_panel.texture = tex

	var s := _current_scale(tex)
	var box_size := Vector2(1000, 200)
	if tex:
		box_size = tex.get_size() * s

	_panel.anchor_left = 0.5
	_panel.anchor_right = 0.5
	_panel.anchor_top = 1.0
	_panel.anchor_bottom = 1.0
	_panel.offset_left = -box_size.x * 0.5
	_panel.offset_right = box_size.x * 0.5
	_panel.offset_top = -box_size.y - bottom_margin
	_panel.offset_bottom = -bottom_margin

	_margin.add_theme_constant_override("margin_left", int(text_area_left * s))
	_margin.add_theme_constant_override("margin_top", int(text_area_top * s))
	_margin.add_theme_constant_override("margin_right", int(text_area_right * s))
	_margin.add_theme_constant_override("margin_bottom", int(text_area_bottom * s))

	# Font otomatis: kelipatan 8 terdekat dari (skala x 4)
	var fs := text_size if text_size > 0 else maxi(8, roundi(s * 4.0 / 8.0) * 8)
	_text_label.add_theme_font_size_override("normal_font_size", fs)
	_text_label.add_theme_constant_override("line_separation", int(fs * 0.4))
	_hint.add_theme_font_size_override("font_size", fs)

	var hx := -(text_area_right * s) - 4.0
	var hy := -(text_area_bottom * s) - 2.0
	_hint.anchor_left = 1.0
	_hint.anchor_right = 1.0
	_hint.anchor_top = 1.0
	_hint.anchor_bottom = 1.0
	_hint.offset_left = hx
	_hint.offset_right = hx
	_hint.offset_top = hy
	_hint.offset_bottom = hy

func _ignore_mouse(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_ignore_mouse(child)

# ------------------------
# ALUR DIALOG
# ------------------------
func _next_line() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
		return

	var line: Dictionary = _lines[_index]

	# Ganti gambar kotak kalau baris ini punya "box"
	if line.has("box") and ResourceLoader.exists(str(line["box"])):
		_apply_box(load(str(line["box"])))
	elif box_texture:
		_apply_box(box_texture)

	var col: Color = line.get("color", text_color)
	_text_label.add_theme_color_override("default_color", col)
	_hint.add_theme_color_override("font_color", col)
	
	var full_text := str(line.get("text", ""))
	_text_label.text = full_text
	_hint.visible = false
	_text_label.visible_characters = 0
	_typing = true

	if _tween:
		_tween.kill()
	var char_count := full_text.length()
	var duration := maxf(char_count / chars_per_second, 0.05)
	_tween = create_tween()
	_tween.tween_property(_text_label, "visible_characters", char_count, duration)
	_tween.tween_callback(_on_typing_done)
	line_started.emit(_index)
	
func _on_typing_done() -> void:
	_typing = false
	_hint.visible = true

func _close() -> void:
	_active = false
	_root.visible = false
	dialog_finished.emit()

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return

	var pressed: bool = event.is_action_pressed("ui_accept") \
		or event.is_action_pressed("interact")
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT:
			pressed = true
	if not pressed:
		return

	get_viewport().set_input_as_handled()
	if _typing:
		# Tekan saat sedang mengetik: langsung tampilkan seluruh kalimat
		_tween.kill()
		_text_label.visible_ratio = 1.0
		_on_typing_done()
	else:
		_next_line()
