class_name LightningBolt
extends HitboxComponent

@export var speed: float = 600.0
@export var direction: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func _ready() -> void:
	area_entered.connect(_on_area_hit)
	body_entered.connect(_on_body_hit)
	get_tree().create_timer(2.0).timeout.connect(queue_free)
	Game.play_sfx("laser_shoot", randf_range(0.95, 1.05), -4.0)

	if animated_sprite != null:
		animated_sprite.flip_h = direction < 0.0
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"default"):
			animated_sprite.play(&"default")

func _on_area_hit(area: Area2D) -> void:
	if area is HurtboxComponent:
		Game.play_sfx("laser_hit", randf_range(0.95, 1.08), -2.0)
	queue_free.call_deferred()

func _on_body_hit(_body: Node2D) -> void:
	queue_free.call_deferred()

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
