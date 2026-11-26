extends Node

const BOX_ALLEN := "res://assets/UI/chatbox boy.png"
const BOX_LUNA := "res://assets/UI/chatbox girl.png"

const COL_ALLEN := Color("#1f2f5c")   # biru tua untuk kotak biru
const COL_LUNA := Color("#5c1f3d")    # merah tua untuk kotak pink
@onready var dialog: DialogBox = $DialogBox

func _ready() -> void:
	Game._apply_mode(Game.SCENE_GAME)   # hanya untuk tes dengan F6
	dialog.dialog_finished.connect(func(): print("dialog selesai"))
	dialog.show_dialog([
	{"text": "Luna, sinyalnya hilang lagi.", "box": BOX_ALLEN, "color": COL_ALLEN},
	{"text": "Tenang, aku cek dulu perangkatnya.", "box": BOX_LUNA, "color": COL_LUNA},
])
