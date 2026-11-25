extends Control
## Placeholder scene gameplay. Ganti dengan game kamu.


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Game.play_sfx("back")
		Game.go_to(Game.SCENE_MAIN_MENU)
		get_viewport().set_input_as_handled()
