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

@onready var allen: AnimatedSprite2D = $Allen
@onready var luna: AnimatedSprite2D = $Luna
@onready var hole_point: Marker2D = $HolePoint   ## taruh di TEPI lubang yang datang dari arah jalan
@onready var dialog = $DialogBox

var _dir: float = 1.0                            ## 1 = kanan, -1 = kiri (dihitung otomatis)
var _faces: Dictionary = {}

func _ready() -> void:
	Game._apply_mode(Game.SCENE_INTRO)   # supaya bisa dites langsung dengan F6

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

	# 2. Dialog sebelum jatuh
	await dialog.say("Luna", "Allen, check your phone. Do you have any signal?")
	await dialog.say("Allen", "Nothing. Zero bars. That's strange, it was fine a minute ago.")
	await dialog.say("Luna", "The whole network just went down. It's a complete signal blackout.")
	await dialog.say("Allen", "A blackout across the entire area? That can't be a coincidence.")
	await dialog.say("Luna", "The signal tower at the end of this road might still be working.")
	await dialog.say("Allen", "Fine, but stay close. I don't like how quiet it is.")
	dialog.close()
	await get_tree().create_timer(0.4).timeout

	# 3. Berjalan lagi: Luna sampai tepi lubang, Allen berhenti di belakang
	var luna_dist := maxf(_dir * (hole_x - luna.global_position.x), 0.0)
	var allen_target_x := hole_x - _dir * follow_gap
	var allen_dist := maxf(_dir * (allen_target_x - allen.global_position.x), 0.0)
	await _walk_group([[allen, allen_dist], [luna, luna_dist]], second_walk_min_time)
	_idle(allen)
	await get_tree().create_timer(0.3).timeout

	# 4. Luna melangkah ke lubang lalu jatuh
	await _step_over(luna)
	await _fall(luna)
	await get_tree().create_timer(1.0).timeout

	# 5. Dialog setelah jatuh
	await dialog.say("Allen", "Luna?! Luna, answer me!")
	await dialog.say("Luna", "Ugh... I'm okay! It's pitch black down here, and still no signal.")
	await dialog.say("Allen", "Stay there. I'm coming down.")
	dialog.close()
	await get_tree().create_timer(0.4).timeout

	# 6. Lanjut ke game
	Game.go_to(Game.SCENE_GAME)

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

func _step_over(sprite: AnimatedSprite2D) -> void:
	if step_over <= 0.0:
		return
	_play(sprite, "walk", int(_dir))
	var t := create_tween()
	t.tween_property(sprite, "global_position:x", sprite.global_position.x + _dir * step_over, step_over_time)
	await t.finished

func _fall(sprite: AnimatedSprite2D) -> void:
	_play(sprite, "jump", int(_dir))
	var t := create_tween().set_parallel(true)
	t.tween_property(sprite, "global_position:x", sprite.global_position.x + _dir * fall_drift, fall_time)
	t.tween_property(sprite, "global_position:y", sprite.global_position.y + fall_height, fall_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await t.finished
	sprite.visible = false

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
