extends Node

enum Screen {
	TOP,
	BOTTOM
}

signal screen_switched(new_screen: Screen)
signal game_over
signal signal_state_changed(is_active: bool)
signal stage_changed(stage_index: int)

var current_stage: int = 0
var total_stages: int = 2

signal player_health_updated(screen: Screen, current: float, max_val: float)
signal player_energy_updated(screen: Screen, current: float, max_val: float)


var active_screen: Screen = Screen.TOP
var is_signal_active: bool = false

#func _unhandled_input(event: InputEvent) -> void:
#	if event.is_action_pressed("switch_screen"):
#		active_screen = Screen.TOP if active_screen == Screen.BOTTOM else Screen.BOTTOM
#		screen_switched.emit(active_screen)
#		print(active_screen)

func trigger_game_over():
	is_signal_active = false
	current_stage = 0
	game_over.emit()
	print("Game Over")
	get_tree().reload_current_scene()

func set_signal_active(active: bool):
	is_signal_active = active
	signal_state_changed.emit(is_signal_active)
	print("Status Sinyal: ", is_signal_active)

func completed_stage() -> void:
	current_stage += 1
	set_signal_active(false)
	if current_stage < total_stages:
		stage_changed.emit(current_stage)
	else:
		print("SELAMAT! ALLEN & LUNA PULANG BERSAMA (WIN)!")
		current_stage = 0
