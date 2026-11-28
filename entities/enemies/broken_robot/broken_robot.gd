class_name BrokenRobot
extends CharacterBody2D

const POWER_UP_SCENE: PackedScene = preload("res://mechanics/power_up/power_up.tscn")
const PowerUpScript = preload("res://mechanics/power_up/power_up.gd")

@export var move_speed: float = 80.0
@export var direction: float = 1.0
@export var face_right_by_default: bool = true
@export_range(0.0, 1.0, 0.05) var drop_chance: float = 0.7

@onready var health_comp: HealthComponent = $HealthComponent
@onready var wall_check: RayCast2D = $WallCheck
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var _is_dead: bool = false

func _ready() -> void:
	direction = 1.0 if direction >= 0.0 else -1.0
	wall_check.target_position.x = absf(wall_check.target_position.x) * direction
	health_comp.died.connect(_on_died)
	_update_visual()

func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	if randf() <= drop_chance and get_parent() != null:
		var item: PowerUpScript = POWER_UP_SCENE.instantiate() as PowerUpScript
		item.random_type = true
		item.allow_damage_boost = true
		item.global_position = global_position
		get_parent().add_child.call_deferred(item)
		item.call_deferred("pop_up")
	queue_free.call_deferred()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if wall_check.is_colliding():
		direction *= -1.0
		wall_check.target_position.x = absf(wall_check.target_position.x) * direction
		_update_visual()

	velocity.x = direction * move_speed
	move_and_slide()

func _update_visual() -> void:
	if animated_sprite == null:
		return
	animated_sprite.flip_h = (direction < 0.0) if face_right_by_default else (direction > 0.0)
	if animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation(&"walk") and animated_sprite.animation != &"walk":
			animated_sprite.play(&"walk")
		elif animated_sprite.sprite_frames.has_animation(&"default") and not animated_sprite.is_playing():
			animated_sprite.play(&"default")
