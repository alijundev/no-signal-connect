class_name BasePlayer
extends CharacterBody2D

@export var assigned_screen: GameBridge.Screen
@export var walk_speed: float = 220.0
@export var sprint_speed: float = 360.0

@export var jump_velocity: float = -400.0
@export var max_jump: int = 2

@export_group("Suara langkah")
@export var step_sound: AudioStream                              ## isi di Inspector Allen dan Luna
@export var step_volume_db: float = 10.0
@export var step_frames: PackedInt32Array = PackedInt32Array()   ## kosong = otomatis

@export_group("Suara lompat")
@export var jump_sound: AudioStream                  ## isi di Inspector Allen dan Luna
@export var jump_volume_db: float = -4.0
@export var double_jump_pitch: float = 1.25          ## nada lompatan kedua (1.0 = sama)
@export var jump_pitch_variation: float = 0.05

@onready var energy_comp: EnergyComponent = $EnergyComponent
@onready var health_comp: HealthComponent = $HealthComponent
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

var can_move: bool = true
var jump_count: int = 0
var facing: int = 1  # 1 = kanan, -1 = kiri
var is_sprinting: bool = false
var is_attacking: bool = false
var _footsteps: Footsteps
var _jump_player: AudioStreamPlayer

func _ready() -> void:
	health_comp.died.connect(GameBridge.trigger_game_over)
	health_comp.health_changed.connect(_on_health_changed)
	energy_comp.energy_changed.connect(_on_energy_changed)
	_on_health_changed.call_deferred(health_comp.current_health, health_comp.max_health)
	_on_energy_changed.call_deferred(energy_comp.current_energy, energy_comp.max_energy)
	play_animation("idle")
		# Suara langkah: hanya berbunyi saat menapak lantai di layar yang aktif
	if animated_sprite and step_sound:
		_footsteps = Footsteps.new()
		add_child(_footsteps)
		_footsteps.setup(animated_sprite, step_sound, step_volume_db, step_frames,
			func(): return is_on_floor() and GameBridge.active_screen == assigned_screen)
	if jump_sound:
		_jump_player = AudioStreamPlayer.new()
		_jump_player.stream = jump_sound
		_jump_player.volume_db = jump_volume_db
		add_child(_jump_player)

func _on_health_changed(current: float, max_val: float) -> void:
	GameBridge.player_health_updated.emit(assigned_screen, current, max_val)

func _on_energy_changed(current: float, max_val: float) -> void:
	GameBridge.player_energy_updated.emit(assigned_screen, current, max_val)

func _physics_process(delta: float) -> void:
	# Gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta
		# Jatuh dari tepi tanpa lompat dihitung sebagai 1 lompatan terpakai
		if jump_count == 0:
			jump_count = 1
	else:
		jump_count = 0

	# Berhenti kalau bukan layar ini atau tidak boleh bergerak
	if GameBridge.active_screen != assigned_screen or not can_move:
		velocity.x = 0.0
		is_sprinting = false
		move_and_slide()
		process_animation()
		return

	# Lompat (maks sesuai max_jump)
	if Input.is_action_just_pressed("jump") and jump_count < max_jump:
		velocity.y = jump_velocity
		jump_count += 1
		play_animation("jump", true)  # langsung putar, tanpa delay
		_play_jump_sound()

	# Gerak kiri-kanan
	var wants_sprint := Input.is_action_pressed("sprint")
	var direction := Input.get_axis("move_left", "move_right")

	var speed: float
	if direction != 0.0 and wants_sprint and energy_comp.can_sprint():
		speed = sprint_speed
		is_sprinting = true
		energy_comp.consume(delta)
	else:
		speed = walk_speed
		is_sprinting = false
		energy_comp.regenerate(delta)

	if direction != 0.0:
		velocity.x = direction * speed
		facing = 1 if direction > 0.0 else -1
	else:
		velocity.x = move_toward(velocity.x, 0.0, 25)

	move_and_slide()
	process_animation()


func _play_jump_sound() -> void:
	if _jump_player == null:
		return
	# jump_count sudah bertambah: 1 = lompatan pertama, 2 = lompatan kedua di udara
	var base_pitch := 1.0 if jump_count <= 1 else double_jump_pitch
	_jump_player.pitch_scale = base_pitch + randf_range(-jump_pitch_variation, jump_pitch_variation)
	_jump_player.play()
	
# ------------------------
# ANIMATION
# ------------------------
func process_animation() -> void:
	if animated_sprite == null or is_attacking:
		return

	if not is_on_floor():
		play_animation("jump")
	elif abs(velocity.x) > 0.1:
		play_animation("walk")
		# Animasi jalan sedikit lebih cepat saat sprint
		animated_sprite.speed_scale = 1.4 if is_sprinting else 1.0
	else:
		play_animation("idle")

	if animated_sprite.animation != "walk_right" and animated_sprite.animation != "walk_left" \
			and animated_sprite.animation != "walk":
		animated_sprite.speed_scale = 1.0

func play_animation(prefix: String, restart: bool = false) -> void:
	if animated_sprite == null or animated_sprite.sprite_frames == null:
		return

	var frames := animated_sprite.sprite_frames
	var dir_name := prefix + ("_right" if facing > 0 else "_left")
	var anim_name := ""

	if frames.has_animation(dir_name):
		# Pakai animasi per arah (idle_right, idle_left, dst.)
		anim_name = dir_name
		animated_sprite.flip_h = false
	elif frames.has_animation(prefix):
		# Pakai satu animasi menghadap kanan + flip_h
		anim_name = prefix
		animated_sprite.flip_h = facing < 0
	else:
		push_warning("Animasi tidak ditemukan: " + dir_name + " / " + prefix)
		return

	if restart or animated_sprite.animation != anim_name:
		animated_sprite.play(anim_name)
		if restart:
			animated_sprite.frame = 0
			animated_sprite.frame_progress = 0.0
