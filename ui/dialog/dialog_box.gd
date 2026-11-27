class_name DialogBox
extends CanvasLayer
## Kotak dialog memakai gambar buatan sendiri + teks Press Start 2P.
## Dua cara pakai:
##   await dialog.say("Allen", "Halo")   ... lalu dialog.close()
##   dialog.show_dialog([{"text": "Halo", "box": "res://...png", "voice": "res://...wav"}])

signal dialog_finished
signal line_started(index: int)
signal _say_advanced

const Pal = preload("res://scripts/ui/retro_theme.gd")

@export_group("Kotak")
@export var box_texture: Texture2D                  ## gambar kotak bawaan
@export var trim_transparent_padding: bool = true
@export var auto_scale: bool = true
@export_range(0.3, 1.0, 0.05) var screen_width_ratio: float = 0.75
@export var box_scale: float = 4.0                  ## dipakai kalau Auto Scale dimatikan
@export var bottom_margin: float = 24.0

@export_group("Pembicara (untuk say)")
@export var allen_box: Texture2D
@export var luna_box: Texture2D
@export var allen_text_color: Color = Color("#1f2f5c")
@export var luna_text_color: Color = Color("#5c1f3d")

@export_group("Suara dialog (looping sampai kalimat selesai)")
@export var allen_voice: AudioStream                ## audio_boy.wav
@export var luna_voice: AudioStream                 ## audio_girl.wav
@export var voice_volume_db: float = 0.0
@export var voice_loop_start: float = 0.0           ## tiap putaran mulai dari detik ke berapa
@export var voice_loop_length: float = 0.0          ## 0 = putar klip penuh; isi (mis. 1.0) untuk memotong tiap putaran

@export_group("Area teks (PIXEL GAMBAR setelah dipotong)")
@export var text_area_left: int = 36
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
var _voice_player: AudioStreamPlayer

var _lines: Array = []
var _index: int = -1
var _typing: bool = false
var _active: bool = false
var _say_mode: bool = false
var _tween: Tween
var _font: Font
var _trim_cache: Dictionary = {}
var _voice_stream: AudioStream

func _ready() -> void:
	layer = 50
	_ensure_ui()
	_root.visible = false

func is_active() -> bool:
	return _active

# ------------------------
# PUBLIK
# ------------------------
## Tampilkan satu kalimat, lalu tunggu pemain menekan tombol.
func say(speaker: String, text: String) -> void:
	_ensure_ui()
	_say_mode = true
	_active = true
	_root.visible = true

	var line := {"text": text}
	match speaker.to_lower():
		"allen":
			if allen_box:
				line["box"] = allen_box
			line["color"] = allen_text_color
			line["voice"] = allen_voice
		"luna":
			if luna_box:
				line["box"] = luna_box
			line["color"] = luna_text_color
			line["voice"] = luna_voice

	_present_line(line)
	await _say_advanced

## Sembunyikan kotak dialog (dipanggil setelah rangkaian say selesai).
func close() -> void:
	_active = false
	_say_mode = false
	_stop_voice()
	if _root:
		_root.visible = false

func show_dialog(lines: Array) -> void:
	_ensure_ui()
	if lines.is_empty():
		dialog_finished.emit()
		return
	_say_mode = false
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

	_voice_player = AudioStreamPlayer.new()
	_voice_player.volume_db = voice_volume_db
	_voice_player.pitch_scale = 1.0
	_voice_player.finished.connect(_on_voice_finished)
	add_child(_voice_player)

# Buang tepi transparan PNG (di-cache)
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

func _current_scale(tex: Texture2D) -> float:
	if tex == null or not auto_scale:
		return box_scale
	var screen_w := get_viewport().get_visible_rect().size.x
	return maxf(1.0, floorf(screen_w * screen_width_ratio / float(tex.get_width())))

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
# SUARA (looping sampai kalimat selesai)
# ------------------------
func _load_voice(value: Variant) -> AudioStream:
	if value is AudioStream:
		return value
	if value is String and str(value) != "" and ResourceLoader.exists(str(value)):
		return load(str(value)) as AudioStream
	return null

func _start_voice_loop() -> void:
	if _voice_stream == null:
		return
	_voice_player.stream = _voice_stream
	_voice_player.volume_db = voice_volume_db
	_voice_player.pitch_scale = 1.0
	_voice_player.play(voice_loop_start)

func _stop_voice() -> void:
	if _voice_player and _voice_player.playing:
		_voice_player.stop()

# Klip habis: ulangi selama teks masih diketik
func _on_voice_finished() -> void:
	if _typing and _voice_stream != null:
		_start_voice_loop()

# Opsional: potong tiap putaran supaya jeda hening di ujung klip tidak terdengar
func _process(_delta: float) -> void:
	if voice_loop_length <= 0.0 or _voice_player == null:
		return
	if _typing and _voice_player.playing \
			and _voice_player.get_playback_position() >= voice_loop_start + voice_loop_length:
		_start_voice_loop()

# ------------------------
# ALUR DIALOG
# ------------------------
func _next_line() -> void:
	_index += 1
	if _index >= _lines.size():
		_close()
		return
	_present_line(_lines[_index])
	line_started.emit(_index)

# Menampilkan satu baris: kotak, warna, suara, dan efek ketik
func _present_line(line: Dictionary) -> void:
	# Pilih gambar kotak (Texture2D atau path), cadangan: kotak bawaan
	var box_value: Variant = line.get("box", null)
	var tex: Texture2D = null
	if box_value is Texture2D:
		tex = box_value
	elif box_value is String and str(box_value) != "":
		var path := str(box_value)
		if ResourceLoader.exists(path):
			tex = load(path) as Texture2D
		else:
			push_warning("Gambar kotak tidak ditemukan: " + path)
	if tex == null:
		tex = box_texture
	if tex != null:
		_apply_box(tex)

	# Warna teks per baris (opsional)
	var col: Color = text_color
	var col_value: Variant = line.get("color", null)
	if col_value is Color:
		col = col_value
	_text_label.add_theme_color_override("default_color", col)
	_hint.add_theme_color_override("font_color", col)

	# Teks
	var full_text := str(line.get("text", ""))
	_text_label.text = full_text
	_hint.visible = false
	_text_label.visible_characters = 0
	_typing = true

	# Efek ketik
	var speed: float = float(line.get("speed", chars_per_second))
	var char_count := full_text.length()
	var duration := maxf(char_count / speed, 0.05)

	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_text_label, "visible_characters", char_count, duration)
	_tween.tween_callback(_on_typing_done)

	# Suara: mulai dari awal, diulang sampai teks selesai
	_stop_voice()
	_voice_stream = _load_voice(line.get("voice", null))
	_start_voice_loop()

func _on_typing_done() -> void:
	_text_label.visible_characters = -1
	_typing = false
	_hint.visible = true
	_stop_voice()   # suara berhenti tepat saat teks selesai

func _close() -> void:
	_active = false
	_typing = false
	_stop_voice()
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
		# Tekan saat mengetik: langsung tampilkan seluruh kalimat, suara berhenti
		_tween.kill()
		_on_typing_done()
	elif _say_mode:
		_say_advanced.emit()
	else:
		_next_line()
