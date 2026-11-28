extends Control

const BUTTON_SIZE := Vector2(170, 30)

@onready var title: PixelTitle = $Content/Title
@onready var subtitle: Label = $Content/Subtitle
@onready var play_again_button: RetroButton = $Content/Menu/PlayAgainButton
@onready var main_menu_button: RetroButton = $Content/Menu/MainMenuButton

func _ready() -> void:
	Game.play_music(Game.MUSIC_MENU)
	play_again_button.custom_minimum_size = BUTTON_SIZE
	main_menu_button.custom_minimum_size = BUTTON_SIZE
	play_again_button.pressed.connect(_on_play_again_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	title.reveal(0.7)

func _on_play_again_pressed() -> void:
	GameBridge.reset_state()
	Game.go_to(Game.SCENE_GAME)

func _on_main_menu_pressed() -> void:
	GameBridge.reset_state()
	Game.go_to(Game.SCENE_MAIN_MENU)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Game.play_sfx("back")
		_on_main_menu_pressed()
		get_viewport().set_input_as_handled()
