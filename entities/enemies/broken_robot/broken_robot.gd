class_name BrokenRobot
extends CharacterBody2D

@export var move_speed: float = 80.0
@export var direction: float = 1.0
@export var face_right_by_default: bool = true

@onready var health_comp: HealthComponent = $HealthComponent
@onready var wall_check: RayCast2D = $WallCheck
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func _ready() -> void:
	health_comp.died.connect(queue_free)
	_update_visual()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if wall_check.is_colliding():
		direction *= -1.0
		wall_check.target_position.x *= -1.0
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
