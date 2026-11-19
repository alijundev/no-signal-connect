extends CanvasLayer

signal attack_succeeded
signal attack_failed

@onready var command_label: Label = $PanelContainer/VBoxContainer/CommandLabel
@onready var command_input: LineEdit = $PanelContainer/VBoxContainer/CommandInput

var command_list: Array[String] = ["sudo zap", "ping -f", "kill -9", "ssh bolt", "exec spark"]

var target_command: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	command_input.text_submitted.connect(_on_command_submitted)

func _on_command_submitted(text: String):
	visible = false
	command_input.release_focus()
	
	if text.strip_edges() == target_command:
		attack_succeeded.emit()
	else:
		attack_failed.emit()
		print("Command salah! Serangan gagal.")

func open_terminal():
	target_command = command_list.pick_random()
	command_label.text = target_command
	command_input.text = ""
	visible = true
	command_input.grab_focus()
