extends Control

@onready var back_button: RetroButton = $Content/Menu/BackButton


func _ready() -> void:
	back_button.pressed.connect(_go_back)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Game.play_sfx("back")
		_go_back()
		get_viewport().set_input_as_handled()


func _go_back() -> void:
	Game.go_to(Game.SCENE_MAIN_MENU)
