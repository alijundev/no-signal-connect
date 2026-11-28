class_name HealthComponent
extends Node

signal health_changed(current: float, max_val: float)
signal died

@export var max_health: float = 100.0
@export var current_health: float

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	current_health = clampf(current_health - amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		died.emit()

func heal(amount: float) -> void:
	current_health = clampf(current_health + amount, 0.0, max_health)
	health_changed.emit(current_health, max_health)
