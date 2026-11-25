extends Control
## Form feedback sederhana. Pesan disimpan ke user://feedback.txt.
## Ganti _on_send_pressed() dengan HTTPRequest kalau mau dikirim ke server / Discord webhook.

const SAVE_PATH := "user://feedback.txt"

@onready var input: TextEdit = $Content/Input
@onready var status: Label = $Content/Status
@onready var send_button: RetroButton = $Content/Menu/SendButton
@onready var back_button: RetroButton = $Content/Menu/BackButton


func _ready() -> void:
	send_button.pressed.connect(_on_send_pressed)
	back_button.pressed.connect(_go_back)
	input.grab_focus()


func _input(event: InputEvent) -> void:
	# ESC saat mengetik: keluar dari kotak teks dulu, ESC lagi untuk kembali.
	if event.is_action_pressed("ui_cancel"):
		if input.has_focus():
			input.release_focus()
			send_button.grab_focus()
		else:
			Game.play_sfx("back")
			_go_back()
		get_viewport().set_input_as_handled()


func _on_send_pressed() -> void:
	var message := input.text.strip_edges()
	if message.is_empty():
		status.text = "WRITE SOMETHING FIRST!"
		return

	var mode := FileAccess.READ_WRITE if FileAccess.file_exists(SAVE_PATH) else FileAccess.WRITE
	var file := FileAccess.open(SAVE_PATH, mode)
	if file == null:
		status.text = "COULD NOT SAVE :("
		return
	file.seek_end()
	file.store_string("[%s]\n%s\n\n" % [Time.get_datetime_string_from_system(), message])
	file.close()

	input.text = ""
	status.text = "THANK YOU! FEEDBACK SAVED."


func _go_back() -> void:
	Game.go_to(Game.SCENE_MAIN_MENU)
