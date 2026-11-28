extends Node2D
## Cutscene pembuka: Allen & Luna berjalan MENUJU HolePoint, mengobrol,
## Luna jalan duluan lalu jatuh ke lubang. Arah dan jarak dihitung otomatis.

const BOX_ALLEN := "res://assets/UI/chatbox boy.png"   # sesuaikan path-nya
const BOX_LUNA := "res://assets/UI/chatbox girl.png"     # sesuaikan path-nya

@export_group("Rute (otomatis menuju HolePoint)")
@export_range(0.1, 0.8, 0.05) var first_walk_ratio: float = 0.4   ## porsi jarak untuk jalan pertama
@export var follow_gap: float = 130.0            ## jarak Allen berhenti di belakang lubang
@export var step_over: float = 40.0              ## Luna melangkah sejauh ini melewati tepi lubang
@export var step_over_time: float = 0.8

@export_group("Kecepatan & durasi")
@export var walk_speed: float = 60.0             ## pixel per detik
@export var first_walk_min_time: float = 4.0
@export var second_walk_min_time: float = 4.5
@export var invert_facing: bool = false          ## centang kalau animasi kiri/kanan tertukar

@export_group("Jatuh")
@export var fall_height: float = 900.0
@export var fall_drift: float = 20.0
@export var fall_time: float = 1.8

@export_group("Suara langkah")
@export var allen_step_sound: AudioStream
@export var luna_step_sound: AudioStream
@export var step_volume_db: float = 10.0
@export var step_frames: PackedInt32Array = PackedInt32Array()   ## kosong = otomatis

@export_group("Pintu jebakan")
@export var trap_pause: float = 0.5            ## Luna terdiam sebelum pintu bergetar
@export var trap_shake_time: float = 0.6
@export var trap_open_distance: float = 72.0   ## tiap sisi bergeser sejauh ini (px)
@export var trap_open_time: float = 0.35
@export var trap_close_delay: float = 0.4      ## jeda setelah Luna jatuh sebelum pintu menutup
@export var trap_close_time: float = 0.3

@onready var allen: AnimatedSprite2D = $Allen
@onready var luna: AnimatedSprite2D = $Luna
@onready var hole_point: Marker2D = $HolePoint   ## taruh di TEPI lubang yang datang dari arah jalan
@onready var dialog = $DialogBox
@onready var trapdoor: Node2D = get_node_or_null("Trapdoor") as Node2D
@onready var trap_sfx: AudioStreamPlayer = get_node_or_null("TrapSfx") as AudioStreamPlayer


var _dir: float = 1.0                            ## 1 = kanan, -1 = kiri (dihitung otomatis)
var _faces: Dictionary = {}
var _allen_tween: Tween
var _door_left_x: float = 0.0
var _door_right_x: float = 0.0
var _skipping: bool = false

func _ready() -> void:
	Game._apply_mode(Game.SCENE_INTRO)   # supaya bisa dites langsung dengan F6
	_add_skip_button()

	if ResourceLoader.exists(BOX_ALLEN):
		dialog.allen_box = load(BOX_ALLEN)
	elif dialog.allen_box == null:
		push_warning("Gambar kotak Allen tidak ditemukan: " + BOX_ALLEN)
	if ResourceLoader.exists(BOX_LUNA):
		dialog.luna_box = load(BOX_LUNA)
	elif dialog.luna_box == null:
		push_warning("Gambar kotak Luna tidak ditemukan: " + BOX_LUNA)

	# Arah = menuju lubang
	var dx := hole_point.global_position.x - luna.global_position.x
	_dir = 1.0 if dx >= 0.0 else -1.0
	print("[Intro] Arah jalan: %s | Luna x=%.0f | HolePoint x=%.0f | jarak=%.0f" % [
		"KANAN" if _dir > 0 else "KIRI", luna.global_position.x, hole_point.global_position.x, absf(dx)])
	if _dir < 0.0:
		push_warning("HolePoint ada di KIRI Luna, jadi mereka berjalan ke kiri. Untuk jalan ke kanan, pindahkan HolePoint/lubang ke kanan Luna.")

	_play(allen, "idle", int(_dir))
	_play(luna, "idle", int(_dir))
	_add_steps(allen, allen_step_sound)
	_add_steps(luna, luna_step_sound)
	await _run()

func _run() -> void:
	await get_tree().create_timer(0.8).timeout

	var hole_x := hole_point.global_position.x
	var total := absf(hole_x - luna.global_position.x)
	var first_dist := total * first_walk_ratio

	# 1. Berjalan bersama (sebagian jarak)
	await _walk_group([[allen, first_dist], [luna, first_dist]], first_walk_min_time)
	_idle(allen)
	_idle(luna)
	await get_tree().create_timer(0.4).timeout

	# 2. Dialog sebelum mendekati menara
	await dialog.say("Luna", "How was work today, Big bro?")
	await dialog.say("Allen", "Nothing special, really. They had me fix a few damaged server cables.")
	await dialog.say("Luna", "I see. Speaking of that, why isn't my laptop picking up any signal at all?")
	await dialog.say("Allen", "Probably just a technical glitch.")
	dialog.close()
	await get_tree().create_timer(0.4).timeout

	# 3. Berjalan lagi: Luna mendekati lubang/arah menara, Allen mengikuti di belakang
	var luna_dist := maxf(_dir * (hole_x - luna.global_position.x), 0.0)
	var allen_target_x := hole_x - _dir * follow_gap
	var allen_dist := maxf(_dir * (allen_target_x - allen.global_position.x), 0.0)

	var luna_walk_time := 0.0
	if luna_dist >= 1.0:
		luna_walk_time = maxf(luna_dist / walk_speed, second_walk_min_time)
	var step_time := step_over / walk_speed if step_over > 0.0 else 0.0
	var allen_time := luna_walk_time + step_time + trap_pause
	_start_allen_walk(allen_dist, allen_time)

	await _walk_group([[luna, luna_dist]], second_walk_min_time)

	# 4. Luna melangkah ke tepi, berucap, lalu terjatuh ke underground
	await _step_over(luna)
	_idle(luna)
	_stop_allen_walk()
	await dialog.say("Luna", "What if I get closer to that signal tower—")
	dialog.close()
	await get_tree().create_timer(trap_pause).timeout
	await _open_trapdoor()
	await _fall(luna)
	await get_tree().create_timer(trap_close_delay).timeout
	await _close_trapdoor()
	await get_tree().create_timer(0.8).timeout

	# 5. Dialog setelah jatuh
	await dialog.say("Allen", "!!!")
	await dialog.say("Allen", "Luna, are you okay? Use your Neurosync to stay connected with me. I'll figure out a way to get your signal back and help you out.")
	await dialog.say("Luna", "Ouch... Alright. Something feels off down here too.")
	dialog.close()
	await get_tree().create_timer(0.4).timeout

	# 6. Lanjut ke game
	_go_to_game()

func _go_to_game() -> void:
	if _skipping:
		return
	_skipping = true
	Game.play_sfx("select")
	Game.go_to(Game.SCENE_GAME)

func _unhandled_input(event: InputEvent) -> void:
	if _skipping:
		return
	if event.is_action_pressed("ui_cancel"):
		_go_to_game()
		get_viewport().set_input_as_handled()

func _add_skip_button() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 60
	add_child(layer)

	var btn := RetroButton.new()
	btn.text = "SKIP [ESC]"
	btn.press_sfx = ""
	btn.focus_mode = Control.FOCUS_NONE
	btn.anchor_left = 1.0
	btn.anchor_right = 1.0
	btn.offset_left = -164.0
	btn.offset_top = 14.0
	btn.offset_right = -16.0
	btn.offset_bottom = 48.0

	var font: Font = Game.RetroTheme.load_font()
	if font != null:
		btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 10)
	btn.add_theme_color_override("font_color", Game.RetroTheme.COL_TEXT)
	btn.add_theme_color_override("font_hover_color", Game.RetroTheme.COL_ACCENT)
	btn.add_theme_color_override("font_outline_color", Game.RetroTheme.COL_OUTLINE)
	btn.add_theme_constant_override("outline_size", 2)
	btn.add_theme_stylebox_override("normal", Game.RetroTheme.pill_style(Game.RetroTheme.COL_EXTRUDE))
	btn.add_theme_stylebox_override("hover", Game.RetroTheme.pill_style(Game.RetroTheme.COL_ALLEN))
	btn.add_theme_stylebox_override("pressed", Game.RetroTheme.pill_style(Game.RetroTheme.COL_ALLEN))
	btn.pressed.connect(_go_to_game)
	layer.add_child(btn)

# ------------------------
# GERAKAN (global_position, selalu searah _dir)
# ------------------------
# moves: [[sprite, jarak_px], ...]  semuanya berjalan bersamaan dengan durasi yang sama
func _walk_group(moves: Array, min_time: float) -> void:
	var longest := 0.0
	for m in moves:
		longest = maxf(longest, absf(float(m[1])))
	if longest < 1.0:
		return
	var duration := maxf(longest / walk_speed, min_time)

	var t := create_tween().set_parallel(true)
	for m in moves:
		var s: AnimatedSprite2D = m[0]
		var dist := absf(float(m[1]))
		if dist < 1.0:
			_idle(s)
			continue
		_play(s, "walk", int(_dir))
		t.tween_property(s, "global_position:x", s.global_position.x + _dir * dist, duration)
	await t.finished

# Allen berjalan terus; durasinya dihitung supaya sampai tepat saat tanah bergetar
func _start_allen_walk(dist: float, time: float) -> void:
	if dist < 1.0:
		_idle(allen)
		return
	_play(allen, "walk", int(_dir))
	_allen_tween = create_tween()
	_allen_tween.tween_property(allen, "global_position:x", allen.global_position.x + _dir * dist, maxf(time, 0.01))
	print("[Intro] Allen berjalan %.0f px dalam %.1f detik (%.0f px/detik)" % [dist, time, dist / maxf(time, 0.01)])

func _stop_allen_walk() -> void:
	if _allen_tween and _allen_tween.is_valid():
		_allen_tween.kill()
	_idle(allen)

func _step_over(sprite: AnimatedSprite2D) -> void:
	if step_over <= 0.0:
		return
	_play(sprite, "walk", int(_dir))
	var t := create_tween()
	t.tween_property(sprite, "global_position:x", sprite.global_position.x + _dir * step_over, step_over / walk_speed)
	await t.finished

func _open_trapdoor() -> void:
	if trapdoor == null:
		return
	var left = trapdoor.get_node_or_null("DoorLeft")
	var right = trapdoor.get_node_or_null("DoorRight")

	# Simpan posisi tertutup, supaya bisa dikembalikan saat menutup
	if left:
		_door_left_x = left.position.x
	if right:
		_door_right_x = right.position.x

	if trap_sfx != null and trap_sfx.stream != null:
		trap_sfx.play()
	else:
		Game.play_sfx("back", 0.65, -2.0)

	# Getar sebentar
	var base_y := trapdoor.position.y
	var shake := create_tween()
	var steps := maxi(int(trap_shake_time / 0.05), 1)
	for i in steps:
		var off := 2.0 if i % 2 == 0 else -2.0
		shake.tween_property(trapdoor, "position:y", base_y + off, 0.05)
	shake.tween_property(trapdoor, "position:y", base_y, 0.02)
	await shake.finished

	# Kedua sisi bergeser membuka
	var open := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if left:
		open.tween_property(left, "position:x", _door_left_x - trap_open_distance, trap_open_time)
	if right:
		open.tween_property(right, "position:x", _door_right_x + trap_open_distance, trap_open_time)

	# Luna mulai jatuh sesaat setelah pintu mulai terbuka
	await get_tree().create_timer(0.12).timeout

func _close_trapdoor() -> void:
	if trapdoor == null:
		return
	var left = trapdoor.get_node_or_null("DoorLeft")
	var right = trapdoor.get_node_or_null("DoorRight")

	if trap_sfx != null and trap_sfx.stream != null:
		trap_sfx.play()
	else:
		Game.play_sfx("back", 0.65, -2.0)

	# Kedua sisi bergeser kembali ke posisi tertutup
	var close := create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	if left:
		close.tween_property(left, "position:x", _door_left_x, trap_close_time)
	if right:
		close.tween_property(right, "position:x", _door_right_x, trap_close_time)
	await close.finished

	# Hentakan kecil saat menutup rapat
	var base_y := trapdoor.position.y
	var thud := create_tween()
	thud.tween_property(trapdoor, "position:y", base_y + 3.0, 0.05)
	thud.tween_property(trapdoor, "position:y", base_y, 0.08)
	await thud.finished
	
func _fall(sprite: AnimatedSprite2D) -> void:
	_play(sprite, "jump", int(_dir))
	var t := create_tween().set_parallel(true)
	t.tween_property(sprite, "global_position:x", sprite.global_position.x + _dir * fall_drift, fall_time)
	t.tween_property(sprite, "global_position:y", sprite.global_position.y + fall_height, fall_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await t.finished
	sprite.visible = false

func _add_steps(sprite: AnimatedSprite2D, stream: AudioStream) -> void:
	if sprite == null or stream == null:
		return
	var fs := Footsteps.new()
	add_child(fs)
	fs.setup(sprite, stream, step_volume_db, step_frames)
# ------------------------
# ANIMASI (mendukung idle_right/idle_left maupun idle + flip_h)
# face: 1 = kanan, -1 = kiri, 0 = pakai arah terakhir
# ------------------------
func _idle(sprite: AnimatedSprite2D) -> void:
	_play(sprite, "idle")

func _play(sprite: AnimatedSprite2D, prefix: String, face: int = 0) -> void:
	if sprite == null:
		return
	if face != 0:
		_faces[sprite] = face
	var f: int = _faces.get(sprite, 1)
	if invert_facing:
		f = -f

	var frames := sprite.sprite_frames
	if frames == null:
		return
	var dir_name := prefix + ("_right" if f > 0 else "_left")
	var anim := ""
	if frames.has_animation(dir_name):
		anim = dir_name
		sprite.flip_h = false
	elif frames.has_animation(prefix):
		anim = prefix
		sprite.flip_h = f < 0
	else:
		push_warning("Animasi tidak ditemukan: " + dir_name + " / " + prefix)
		return
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
