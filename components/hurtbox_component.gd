class_name HurtboxComponent
extends Area2D

@export var health_comp: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D):
	if area is HitboxComponent and health_comp != null:
		health_comp.take_damage(area.damage)
