extends HitboxComponent

@export var speed: float = 600
@export var direction: float = 1.0

func _ready() -> void:
	area_entered.connect(clear)
	body_entered.connect(clear)
	get_tree().create_timer(2).timeout.connect(queue_free)

func clear(_body: Node2D):
	queue_free()
	
func _physics_process(delta: float) -> void:
	position.x += direction * speed * delta
