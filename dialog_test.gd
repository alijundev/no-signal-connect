extends Node

@onready var dialog: DialogBox = $DialogBox

func _ready() -> void:
	Game._apply_mode(Game.SCENE_GAME)   # hanya untuk tes dengan F6
	dialog.dialog_finished.connect(func(): print("dialog selesai"))
	dialog.show_dialog([
		{"name": "Allen", "text": "Luna, sinyalnya hilang lagi."},
		{"name": "Luna", "text": "Tenang, aku cek dulu perangkatnya.", "side": "right"},
		{"name": "Allen", "text": "Hati-hati, jalannya licin."},
	])
