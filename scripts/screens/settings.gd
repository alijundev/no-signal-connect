extends Control
## Pengaturan: volume, layar penuh, efek CRT. Tersimpan otomatis lewat Game.

@onready var volume: RetroStepper = $Content/Menu/VolumeOption
@onready var fullscreen: RetroStepper = $Content/Menu/FullscreenOption
@onready var crt: RetroStepper = $Content/Menu/CrtOption
@onready var back_button: RetroButton = $Content/Menu/BackButton


func _ready() -> void:
	var percents := PackedStringArray()
	for i in range(0, 11):
		percents.append("%d%%" % (i * 10))
	volume.options = percents
	volume.index = roundi(Game.master_volume * 10.0)
	volume.value_changed.connect(func(i: int): Game.set_master_volume(i / 10.0))

	fullscreen.options = PackedStringArray(["OFF", "ON"])
	fullscreen.index = 1 if Game.fullscreen else 0
	fullscreen.value_changed.connect(func(i: int): Game.set_fullscreen(i == 1))

	crt.options = PackedStringArray(["OFF", "ON"])
	crt.index = 1 if Game.crt_enabled else 0
	crt.value_changed.connect(func(i: int): Game.set_crt_enabled(i == 1))

	back_button.pressed.connect(_go_back)
	# F11 bisa mengubah layar penuh dari mana saja: sinkronkan tampilan.
	Game.settings_changed.connect(_refresh)


func _refresh() -> void:
	fullscreen.index = 1 if Game.fullscreen else 0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Game.play_sfx("back")
		_go_back()
		get_viewport().set_input_as_handled()


func _go_back() -> void:
	Game.go_to(Game.SCENE_MAIN_MENU)
