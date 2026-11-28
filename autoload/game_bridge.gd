extends Node

enum Screen {
	TOP,
	BOTTOM
}

signal screen_switched(new_screen: Screen)
signal game_over
signal signal_state_changed(is_active: bool)
signal stage_changed(stage_index: int)
signal game_won

var current_stage: int = 0
var total_stages: int = 2

signal player_health_updated(screen: Screen, current: float, max_val: float)
signal player_energy_updated(screen: Screen, current: float, max_val: float)
signal player_buff_updated(screen: Screen, buff_text: String)


var active_screen: Screen = Screen.TOP
var is_signal_active: bool = false
var is_game_over: bool = false

func reset_state() -> void:
	current_stage = 0
	is_signal_active = false
	is_game_over = false
	active_screen = Screen.TOP

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	is_signal_active = false
	game_over.emit()
	print("Game Over")

func set_signal_active(active: bool) -> void:
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
		game_won.emit()      # <-- BARU
