class_name HurtboxComponent
extends Area2D

@export var health_comp: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	var parent_node: Node = get_parent()
	if parent_node is BasePlayer and (parent_node as BasePlayer).has_shield():
		return
	if area is HitboxComponent and health_comp != null:
		health_comp.take_damage((area as HitboxComponent).damage)
