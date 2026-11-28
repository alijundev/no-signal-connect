class_name Footsteps
extends Node
## Suara langkah yang disinkronkan dengan frame animasi "walk".
## Langkah berbunyi pada frame tertentu (bawaan: frame 0 dan frame tengah).

const MIN_GAP := 0.08   # detik, mencegah bunyi ganda

var _sprite: AnimatedSprite2D
var _player: AudioStreamPlayer
var _stream: AudioStream
var _frames: PackedInt32Array = PackedInt32Array()
var _can_step: Callable = Callable()
var _pitch_variation := 0.06
var _last_time := -1.0


## frames kosong = otomatis (frame 0 dan frame tengah animasi).
## can_step (opsional): fungsi yang mengembalikan true kalau boleh berbunyi.
func setup(sprite: AnimatedSprite2D, stream: AudioStream, volume_db := -6.0,
		frames := PackedInt32Array(), can_step := Callable(), pitch_variation := 0.06) -> void:
	_sprite = sprite
	_stream = stream
	_frames = frames
	_can_step = can_step
	_pitch_variation = pitch_variation

	_player = AudioStreamPlayer.new()
	_player.stream = stream
	_player.volume_db = volume_db
	add_child(_player)

	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_changed.connect(_on_frame_changed)


func _on_frame_changed() -> void:
	if _sprite == null or _stream == null:
		return
	if not String(_sprite.animation).begins_with("walk") or not _sprite.is_playing():
		return
	if not _is_step_frame():
		return
	if _can_step.is_valid() and not _can_step.call():
		return

	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_time < MIN_GAP:
		return
	_last_time = now

	# Sprint (speed_scale > 1) membuat nada sedikit lebih tinggi
	var speed := maxf(_sprite.speed_scale, 0.1)
	_player.pitch_scale = 1.0 + (speed - 1.0) * 0.3 + randf_range(-_pitch_variation, _pitch_variation)
	_player.play()


func _is_step_frame() -> bool:
	if not _frames.is_empty():
		return _sprite.frame in _frames
	if _sprite.sprite_frames == null:
		return false
	var count := _sprite.sprite_frames.get_frame_count(_sprite.animation)
	if count <= 1:
		return true
	return _sprite.frame == 0 or _sprite.frame == int(count * 0.5)
