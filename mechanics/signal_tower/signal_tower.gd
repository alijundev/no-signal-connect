extends Area2D

@onready var prompt_label: Label = $PromptLabel
@onready var color_rect: ColorRect = $ColorRect

@onready var cable_puzzle: CanvasLayer = $CablePuzzle

var is_activated: bool = false
var player_in_range: bool = false

func _ready() -> void:
	prompt_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	cable_puzzle.puzzle_solved.connect(activate_tower)

func _on_body_entered(body: Node2D):
	if body is BasePlayer and not is_activated:
		player_in_range = true
		prompt_label.visible = true

func _on_body_exited(body: Node2D):
	if body is BasePlayer:
		player_in_range = false
		prompt_label.visible = false
		cable_puzzle.close_puzzle()

func activate_tower():
	is_activated = true
	prompt_label.visible = false
	color_rect.color = Color.GREEN
	GameBridge.set_signal_active(true)

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and not is_activated and GameBridge.active_screen == GameBridge.Screen.TOP and event.is_action_pressed("interact"):
		cable_puzzle.open_puzzle()
