class_name LaptopTerminal
extends CanvasLayer

signal attack_succeeded
signal attack_failed

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@onready var title_label: Label = $LaptopFrame/ScreenMargin/VBoxContainer/TitleLabel
@onready var command_label: Label = $LaptopFrame/ScreenMargin/VBoxContainer/CommandLabel
@onready var command_input: LineEdit = $LaptopFrame/ScreenMargin/VBoxContainer/CommandInput

var _stage_commands: Array[PackedStringArray] = [
	PackedStringArray(["sudo zap", "ping -f", "kill -9", "ssh bolt", "exec spark"]),
	PackedStringArray([
		"sudo ./zap --force",
		"ssh -p 22 root@bolt",
		"kill -9 --signal=ARC",
		"systemctl start spark",
		"nmap -sV --script=zap"
	]),
]

var target_command: String = ""

func _ready() -> void:
	visible = false
	_apply_terminal_style()
	command_input.text_submitted.connect(_on_command_submitted)

func _apply_terminal_style() -> void:
	var font: Font = RetroTheme.load_font()
	if font != null:
		title_label.add_theme_font_override("font", font)
		command_label.add_theme_font_override("font", font)
		command_input.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 12)
	title_label.add_theme_color_override("font_color", RetroTheme.COL_CYAN)
	command_label.add_theme_font_size_override("font_size", 16)
	command_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	command_input.add_theme_font_size_override("font_size", 12)
	command_input.add_theme_color_override("font_color", Color("#76ff7a"))
	command_input.add_theme_stylebox_override("normal", RetroTheme.box(Color("#0c1518"), RetroTheme.COL_CYAN, 2, 8, 6))
	command_input.add_theme_stylebox_override("focus", RetroTheme.box(Color("#0c1518"), RetroTheme.COL_ACCENT, 2, 8, 6))

func _on_command_submitted(text: String) -> void:
	visible = false
	command_input.release_focus()

	if text.strip_edges() == target_command:
		attack_succeeded.emit()
	else:
		attack_failed.emit()
		print("Command salah! Serangan gagal.")

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_terminal()
		get_viewport().set_input_as_handled()

func close_terminal() -> void:
	visible = false
	command_input.release_focus()
	attack_failed.emit()

func open_terminal() -> void:
	var stage_idx: int = clampi(GameBridge.current_stage, 0, _stage_commands.size() - 1)
	var commands: PackedStringArray = _stage_commands[stage_idx]
	target_command = commands[randi() % commands.size()]
	command_label.text = target_command
	command_input.text = ""
	visible = true
	command_input.grab_focus()
