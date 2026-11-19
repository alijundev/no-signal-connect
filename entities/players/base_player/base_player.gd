class_name BasePlayer
extends CharacterBody2D

@export var assigned_screen: GameBridge.Screen
@export var walk_speed: float = 220.0
@export var sprint_speed: float = 360.0

@export var jump_velocity: float =  -400.0
@export var max_jump: int = 2

@onready var energy_comp: EnergyComponent = $EnergyComponent
@onready var health_comp: HealthComponent = $HealthComponent

var can_move: bool = true 

var jump_count: int = 0

func _ready() -> void:
	health_comp.died.connect(GameBridge.trigger_game_over)
	health_comp.health_changed.connect(_on_health_changed)
	energy_comp.energy_changed.connect(_on_energy_changed)
	_on_health_changed.call_deferred(health_comp.current_health, health_comp.max_health)
	_on_energy_changed.call_deferred(energy_comp.current_energy, energy_comp.max_energy)
	

func _on_health_changed(current: float, max_val: float):
	GameBridge.player_health_updated.emit(assigned_screen, current, max_val)

func _on_energy_changed(current: float, max_val: float):
	GameBridge.player_energy_updated.emit(assigned_screen, current, max_val)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
	
	# stop if not in this screen or cannot move(if laptop terminal open)
	if GameBridge.active_screen != assigned_screen or not can_move:
		velocity.x = 0.0
		move_and_slide()
		return
	
	# jump(max 2)
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		velocity.y = jump_velocity
		jump_count += 1
	
	# move left and right
	var is_sprint = Input.is_action_pressed("sprint")
	var direction := Input.get_axis("move_left", "move_right")
	
	var speed: float
	if direction != 0.0 and is_sprint and energy_comp.can_sprint():
		speed = sprint_speed
		energy_comp.consume(delta)
	else:
		speed = walk_speed
		energy_comp.regenerate(delta)
	
	
	
	if direction != 0.0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, 25)

	move_and_slide()
