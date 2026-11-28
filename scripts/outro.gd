extends Node2D
## Cutscene penutup: Luna berada di dalam lubang jalan yang terbuka,
## Allen mengambil kabel tua untuk menarik Luna naik ke tepi kiri,
## lalu keduanya melompati lubang dan berjalan pulang bersama ke arah kanan.

const BOX_ALLEN := "res://assets/UI/chatbox boy.png"
const BOX_LUNA := "res://assets/UI/chatbox girl.png"

@export var walk_speed: float = 115.0
@export var climb_time: float = 0.9
@export var allen_step_sound: AudioStream
@export var luna_step_sound: AudioStream
@export var allen_jump_sound: AudioStream
@export var luna_jump_sound: AudioStream
@export var step_volume_db: float = -6.0
@export var jump_volume_db: float = -4.0

@onready var allen: AnimatedSprite2D = $Allen
@onready var luna: AnimatedSprite2D = $Luna
@onready var dialog: DialogBox = $DialogBox
@onready var cable_line: Line2D = $CableLine
@onready var cable_coil: ColorRect = $CableCoil

var _skipping: bool = false
var _allen_jump_player: AudioStreamPlayer
var _luna_jump_player: AudioStreamPlayer

func _ready() -> void:
	Game._apply_mode(Game.SCENE_OUTRO)
	_add_skip_hint()

	if ResourceLoader.exists(BOX_ALLEN):
		dialog.allen_box = load(BOX_ALLEN) as Texture2D
	if ResourceLoader.exists(BOX_LUNA):
		dialog.luna_box = load(BOX_LUNA) as Texture2D

	_play(allen, "idle", 1)
	_play(luna, "idle", -1)
	_add_steps(allen, allen_step_sound)
	_add_steps(luna, luna_step_sound)
	_allen_jump_player = _make_sfx_player(allen_jump_sound, jump_volume_db)
	_luna_jump_player = _make_sfx_player(luna_jump_sound, jump_volume_db)

	if cable_line != null:
		cable_line.visible = false

	await _run()

func _run() -> void:
	await get_tree().create_timer(0.6).timeout
	if _skipping or not is_inside_tree():
		return

	# 1. Luna memanggil dari bawah lubang
	await dialog.say("Luna", "Big bro, down here... I can see you.")
	if _skipping or not is_inside_tree():
		return

	# 2. Allen melihat celah & mengambil kabel tua di dekatnya
	await dialog.say("Allen", "I see an opening. Hold on!")
	dialog.close()
	if _skipping or not is_inside_tree():
		return

	await _grab_and_pull_luna()
	if _skipping or not is_inside_tree():
		return

	# 3. Dialog setelah Luna selamat naik di tepi kiri (berdiri di jalan solid)
	_play(allen, "idle", 1)
	_play(luna, "idle", -1)
	await get_tree().create_timer(0.3).timeout
	await dialog.say("Allen", "Thank goodness you're safe. Let's head home before those robots catch up.")
	if _skipping or not is_inside_tree():
		return
	await dialog.say("Luna", "Yeah, Let's go home.")
	dialog.close()
	if _skipping or not is_inside_tree():
		return

	# 4. Keduanya melompati lubang secara nyata lalu berjalan pulang ke kanan
	await _jump_and_walk_home()
	if not _skipping:
		_finish_outro()

func _grab_and_pull_luna() -> void:
	# Allen berjalan ke gulungan kabel tua di tepi kiri lubang (masih di jalan solid x < 192)
	var grab_x: float = 172.0
	_play(allen, "walk", 1)
	var t_grab: Tween = create_tween()
	t_grab.tween_property(allen, "global_position:x", grab_x, 0.45)
	await t_grab.finished
	_play(allen, "idle", 1)

	if cable_coil != null:
		cable_coil.visible = false

	# Turunkan kabel ke dalam lubang menuju Luna
	if cable_line != null:
		var start_pt: Vector2 = Vector2(grab_x + 16.0, 354.0)
		var end_pt: Vector2 = Vector2(luna.global_position.x, luna.global_position.y - 14.0)
		cable_line.points = PackedVector2Array([start_pt, start_pt])
		cable_line.visible = true

		var t_drop: Tween = create_tween()
		t_drop.tween_method(
			func(pos: Vector2) -> void:
				cable_line.set_point_position(1, pos),
			start_pt,
			end_pt,
			0.45
		)
		await t_drop.finished

	await get_tree().create_timer(0.2).timeout

	# Tarik Luna naik lurus ke atas mulut lubang
	_play(luna, "jump", -1)
	var lift_y: float = 302.0
	var t_pull: Tween = create_tween().set_parallel(true)
	t_pull.tween_property(luna, "global_position:y", lift_y, climb_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if cable_line != null:
		t_pull.tween_method(
			func(y_val: float) -> void:
				cable_line.set_point_position(1, Vector2(luna.global_position.x, y_val - 14.0)),
			luna.global_position.y,
			lift_y,
			climb_time
		)
	await t_pull.finished

	# Ayunkan Luna mendarat di jalan solid sebelah kiri sementara Allen mundur sedikit
	var t_land: Tween = create_tween().set_parallel(true)
	t_land.tween_property(luna, "global_position", Vector2(174.0, 338.0), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_play(allen, "walk", 1)
	t_land.tween_property(allen, "global_position:x", 116.0, 0.45)
	if cable_line != null:
		t_land.tween_method(
			func(pos: Vector2) -> void:
				cable_line.set_point_position(0, Vector2(allen.global_position.x + 16.0, 354.0))
				cable_line.set_point_position(1, pos),
			Vector2(luna.global_position.x, lift_y - 14.0),
			Vector2(174.0, 338.0),
			0.45
		)
	await t_land.finished

	if cable_line != null:
		cable_line.visible = false

func _jump_and_walk_home() -> void:
	# Luna melompati lubang lebih dulu, disusul Allen di belakangnya
	_traverse_hole_and_walk(luna, 338.0, _luna_jump_player, 860.0)
	await get_tree().create_timer(0.4).timeout
	if _skipping or not is_inside_tree():
		return
	await _traverse_hole_and_walk(allen, 341.0, _allen_jump_player, 780.0)
	await get_tree().create_timer(0.4).timeout

func _traverse_hole_and_walk(sprite: AnimatedSprite2D, ground_y: float, jump_player: AudioStreamPlayer, final_x: float) -> void:
	var takeoff_x: float = 186.0
	var land_x: float = 404.0

	# Jalan ke tepi lubang
	var pre_dist: float = maxf(takeoff_x - sprite.global_position.x, 0.0)
	if pre_dist > 1.0:
		_play(sprite, "walk", 1)
		var t_pre: Tween = create_tween()
		t_pre.tween_property(sprite, "global_position:x", takeoff_x, pre_dist / walk_speed)
		await t_pre.finished

	if _skipping or not is_inside_tree():
		return

	# Melompati lubang dengan kurva parabola
	_play(sprite, "jump", 1)
	if jump_player != null:
		jump_player.play()
	var jump_dur: float = 0.72
	var jump_height: float = 86.0
	var t_jump: Tween = create_tween()
	t_jump.tween_method(
		func(u: float) -> void:
			var x_pos: float = lerpf(takeoff_x, land_x, u)
			var y_arc: float = 4.0 * jump_height * u * (1.0 - u)
			sprite.global_position = Vector2(x_pos, ground_y - y_arc),
		0.0,
		1.0,
		jump_dur
	)
	await t_jump.finished

	if _skipping or not is_inside_tree():
		return

	# Jalan pulang ke arah kanan layar
	_play(sprite, "walk", 1)
	var post_dist: float = maxf(final_x - land_x, 0.0)
	var t_post: Tween = create_tween()
	t_post.tween_property(sprite, "global_position:x", final_x, post_dist / walk_speed)
	await t_post.finished

func _finish_outro() -> void:
	_skipping = true
	Game.go_to(Game.SCENE_MAIN_MENU)

func _unhandled_input(event: InputEvent) -> void:
	if _skipping:
		return
	if event.is_action_pressed("ui_cancel"):
		Game.play_sfx("select")
		_finish_outro()
		get_viewport().set_input_as_handled()

func _add_skip_hint() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 60
	add_child(layer)

	var label := Label.new()
	label.text = "[ESC] SKIP"
	label.anchor_left = 1.0
	label.anchor_right = 1.0
	label.offset_left = -150.0
	label.offset_top = 14.0
	label.offset_right = -16.0
	label.offset_bottom = 38.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.modulate = Color(1.0, 1.0, 1.0, 0.7)
	var font: Font = Game.RetroTheme.load_font()
	if font != null:
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 10)
	layer.add_child(label)

func _add_steps(sprite: AnimatedSprite2D, stream: AudioStream) -> void:
	if sprite == null or stream == null:
		return
	var fs := Footsteps.new()
	add_child(fs)
	fs.setup(sprite, stream, step_volume_db)

func _make_sfx_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	if stream == null:
		return null
	var p := AudioStreamPlayer.new()
	p.stream = stream
	p.volume_db = volume_db
	add_child(p)
	return p

func _play(sprite: AnimatedSprite2D, prefix: String, face: int = 1) -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	var dir_name: String = prefix + ("_right" if face > 0 else "_left")
	if sprite.sprite_frames.has_animation(dir_name):
		sprite.flip_h = false
		if sprite.animation != dir_name or not sprite.is_playing():
			sprite.play(dir_name)
	elif sprite.sprite_frames.has_animation(prefix):
		sprite.flip_h = face < 0
		if sprite.animation != prefix or not sprite.is_playing():
			sprite.play(prefix)
