class_name OneWayGate
extends Node2D

signal gate_closed

@onready var blocker_wall: StaticBody2D = $BlockerWall
@onready var wall_collision: CollisionShape2D = $BlockerWall/CollisionShape2D
@onready var pass_trigger: Area2D = $PassTrigger
@onready var trigger_collision: CollisionShape2D = $PassTrigger/CollisionShape2D
@onready var visual_node: CanvasItem = get_node_or_null("BlockerWall/ColorRect") as CanvasItem

var is_closed: bool = false

func _ready() -> void:
	wall_collision.disabled = true
	pass_trigger.body_entered.connect(_on_pass_trigger_body_entered)
	_update_visual()

func _on_pass_trigger_body_entered(body: Node2D) -> void:
	if body is BasePlayer and not is_closed:
		close_gate()

func close_gate() -> void:
	is_closed = true
	wall_collision.set_deferred("disabled", false)
	trigger_collision.set_deferred("disabled", true)
	Game.play_sfx("back", 0.75)
	_update_visual()
	gate_closed.emit()

func _update_visual() -> void:
	if visual_node != null:
		visual_node.modulate = Color(1.0, 0.25, 0.25, 0.9) if is_closed else Color(0.5, 0.5, 0.5, 0.25)
