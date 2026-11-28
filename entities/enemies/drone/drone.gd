class_name Drone
extends CharacterBody2D

@export var move_speed: float = 110.0
@export var direction: float = 1.0
@export var patrol_distance: float = 180.0
@export var hover_amplitude: float = 14.0
@export var hover_speed: float = 3.0
@export var face_right_by_default: bool = true

@onready var health_comp: HealthComponent = $HealthComponent
@onready var wall_check: RayCast2D = $WallCheck
@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

var _origin_x: float = 0.0
var _origin_y: float = 0.0
var _hover_time: float = 0.0

func _ready() -> void:
	_origin_x = global_position.x
	_origin_y = global_position.y
	direction = 1.0 if direction >= 0.0 else -1.0
	wall_check.target_position.x = absf(wall_check.target_position.x) * direction
	health_comp.died.connect(queue_free)
	_update_visual()

func _physics_process(delta: float) -> void:
	_hover_time += delta

	var hit_wall: bool = wall_check.is_colliding()
	var reached_limit: bool = patrol_distance > 0.0 and (
		(direction > 0.0 and global_position.x >= _origin_x + patrol_distance)
		or (direction < 0.0 and global_position.x <= _origin_x - patrol_distance)
	)
	if hit_wall or reached_limit:
		direction *= -1.0
		wall_check.target_position.x = absf(wall_check.target_position.x) * direction
		_update_visual()

	var target_y: float = _origin_y + sin(_hover_time * hover_speed) * hover_amplitude
	velocity.x = direction * move_speed
	velocity.y = (target_y - global_position.y) * 8.0
	move_and_slide()

func _update_visual() -> void:
	if animated_sprite == null:
		return
	animated_sprite.flip_h = (direction < 0.0) if face_right_by_default else (direction > 0.0)
	if animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation(&"hover") and animated_sprite.animation != &"hover":
			animated_sprite.play(&"hover")
		elif animated_sprite.sprite_frames.has_animation(&"default") and not animated_sprite.is_playing():
			animated_sprite.play(&"default")
