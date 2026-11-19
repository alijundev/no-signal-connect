extends CharacterBody2D


@export var move_speed: float = 80
@export var direction: float = 1.0

@onready var health_comp: HealthComponent = $HealthComponent
@onready var wall_check: RayCast2D = $WallCheck

func _ready() -> void:
	health_comp.died.connect(queue_free)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if wall_check.is_colliding():
		direction *= -1.0
		wall_check.target_position.x *= -1.0
	
	velocity.x = direction * move_speed 
	move_and_slide()
