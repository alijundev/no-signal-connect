class_name LightningBolt
extends HitboxComponent

@export var speed: float = 600.0
@export var direction: float = 1.0

@onready var animated_sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

func _ready() -> void:
	area_entered.connect(_on_hit)
	body_entered.connect(_on_hit)
	get_tree().create_timer(2.0).timeout.connect(queue_free)

	if animated_sprite != null:
		animated_sprite.flip_h = direction < 0.0
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(&"default"):
			animated_sprite.play(&"default")

func _on_hit(_other: Node2D) -> void:
	queue_free.call_deferred()

func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
