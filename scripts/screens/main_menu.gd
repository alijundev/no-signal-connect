extends Control
## Menu utama. Urutan intro: judul "diketik" -> subtitle -> tombol muncul satu-satu.
const BUTTON_SIZE := Vector2(150, 30)   # lebar x tinggi tombol (font tetap 16)
const BUTTON_SPACING := 8              # jarak antar tombol

@onready var title: PixelTitle = $Content/Title
@onready var subtitle: Label = $Content/Subtitle
@onready var version_label: Label = $Footer/Version
@onready var play_button: RetroButton = $Content/Menu/PlayButton
@onready var settings_button: RetroButton = $Content/Menu/SettingsButton
@onready var feedback_button: RetroButton = $Content/Menu/FeedbackButton
@onready var credits_button: RetroButton = $Content/Menu/CreditsButton
@onready var exit_button: RetroButton = $Content/Menu/ExitButton

var _buttons: Array[RetroButton] = []


func _ready() -> void:
	Game.play_music(Game.MUSIC_MENU)
	_buttons = [play_button, settings_button, feedback_button, credits_button, exit_button]
	for b in _buttons:
		b.custom_minimum_size = BUTTON_SIZE
	$Content/Menu.add_theme_constant_override("separation", BUTTON_SPACING)
	version_label.text = "V%s" % ProjectSettings.get_setting("application/config/version", "0.1.0")

	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(Game.go_to.bind(Game.SCENE_SETTINGS))
	feedback_button.pressed.connect(Game.go_to.bind(Game.SCENE_FEEDBACK))
	credits_button.pressed.connect(Game.go_to.bind(Game.SCENE_CREDITS))
	exit_button.pressed.connect(Game.quit_game)

	_play_intro()


func _play_intro() -> void:
	title.visible_chars = 0
	subtitle.modulate.a = 0.0
	for b in _buttons:
		b.modulate.a = 0.0
		b.mouse_filter = Control.MOUSE_FILTER_IGNORE # belum bisa di-hover saat intro

	var tw := create_tween()
	tw.tween_interval(0.5)
	tw.tween_callback(title.reveal.bind(0.8))
	tw.tween_interval(1.0)
	tw.tween_callback(func(): subtitle.modulate.a = 1.0)
	tw.tween_interval(0.25)
	for i in _buttons.size():
		tw.tween_callback(_show_button.bind(i))
		tw.tween_interval(0.09)
	tw.tween_callback(_finish_intro)


func _show_button(i: int) -> void:
	_buttons[i].modulate.a = 1.0
	Game.play_sfx("move", 0.8 + i * 0.12)


func _finish_intro() -> void:
	for b in _buttons:
		b.mouse_filter = Control.MOUSE_FILTER_STOP
	# Subtitle berkedip seperti "PRESS START"
	var blink := create_tween().set_loops()
	blink.tween_property(subtitle, "modulate:a", 1.0, 0.0)
	blink.tween_interval(0.9)
	blink.tween_property(subtitle, "modulate:a", 0.25, 0.0)
	blink.tween_interval(0.5)

func _on_play_pressed() -> void:
	GameBridge.reset_state()
	Game.go_to(Game.SCENE_GAME if Game.intro_watched else Game.SCENE_INTRO)
