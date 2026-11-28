class_name EnergyComponent
extends Node

signal energy_changed(current: float, max_val: float)

@export var max_energy: float = 100.0
@export var drain_rate: float = 35.0
@export var regen_rate: float = 25.0
@export var recovery_threshold: float = 25.0

var current_energy: float
var is_exhausted: bool = false

func _ready() -> void:
	current_energy = max_energy

func can_sprint() -> bool:
	return not is_exhausted and current_energy > 0.0

func consume(delta: float) -> void:
	var prev_energy: float = current_energy
	var prev_exhausted: bool = is_exhausted
	current_energy = clampf(current_energy - (drain_rate * delta), 0.0, max_energy)

	if current_energy <= 0.0:
		is_exhausted = true

	if not is_equal_approx(prev_energy, current_energy) or prev_exhausted != is_exhausted:
		energy_changed.emit(current_energy, max_energy)

func regenerate(delta: float) -> void:
	var prev_energy: float = current_energy
	var prev_exhausted: bool = is_exhausted
	current_energy = clampf(current_energy + (regen_rate * delta), 0.0, max_energy)

	if is_exhausted and current_energy >= recovery_threshold:
		is_exhausted = false

	if not is_equal_approx(prev_energy, current_energy) or prev_exhausted != is_exhausted:
		energy_changed.emit(current_energy, max_energy)
