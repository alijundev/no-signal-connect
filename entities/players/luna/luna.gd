extends BasePlayer

const LIGHTNING_SCENE = preload("res://mechanics/lightning_bolt/lightning_bolt.tscn")

@onready var laptop_terminal: CanvasLayer = $LaptopTerminal

var facing_direction: float = 1.0

func _ready() -> void:
	super._ready()
	laptop_terminal.attack_succeeded.connect(_on_attack_succeeded)
	laptop_terminal.attack_failed.connect(_on_attack_failed)

func  _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if velocity.x != 0.0:
		facing_direction = sign(velocity.x)

func _unhandled_input(event: InputEvent) -> void:
	if GameBridge.active_screen == GameBridge.Screen.BOTTOM and GameBridge.is_signal_active and can_move and event.is_action_pressed("interact"):
		can_move = false
		laptop_terminal.open_terminal()

func _on_attack_succeeded():
	print("Atack")
	can_move = true
	var bolt: Area2D = LIGHTNING_SCENE.instantiate()
	bolt.global_position = global_position
	bolt.direction = facing_direction	
	get_parent().add_child(bolt)	

func _on_attack_failed():
	can_move = true
	
