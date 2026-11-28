class_name LaptopTerminal
extends CanvasLayer

signal attack_succeeded
signal attack_failed

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")
const SLIDE_OFFSET_Y: float = 560.0
const OPEN_DURATION: float = 0.28
const CLOSE_DURATION: float = 0.20

@onready var laptop_frame: TextureRect = $LaptopFrame
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
var _rest_y: float = 0.0
var _tween: Tween
var _is_closing: bool = false


func _ready() -> void:
	visible = false
	_rest_y = laptop_frame.position.y
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
	if _is_closing:
		return
	var is_correct: bool = text.strip_edges() == target_command
	if not is_correct:
		print("Command salah! Serangan gagal.")
	_animate_close(is_correct)


func _input(event: InputEvent) -> void:
	if visible and not _is_closing and event.is_action_pressed("ui_cancel"):
		close_terminal()
		get_viewport().set_input_as_handled()


func close_terminal() -> void:
	if _is_closing or not visible:
		return
	_animate_close(false)


func open_terminal() -> void:
	_kill_tween()
	_is_closing = false

	var stage_idx: int = clampi(GameBridge.current_stage, 0, _stage_commands.size() - 1)
	var commands: PackedStringArray = _stage_commands[stage_idx]
	target_command = commands[randi() % commands.size()]
	command_label.text = target_command
	command_input.text = ""
	command_input.editable = true

	laptop_frame.position.y = _rest_y + SLIDE_OFFSET_Y
	laptop_frame.modulate.a = 0.0
	visible = true

	_tween = create_tween().set_parallel(true)
	_tween.tween_property(laptop_frame, "position:y", _rest_y, OPEN_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(laptop_frame, "modulate:a", 1.0, OPEN_DURATION * 0.7)
	_tween.chain().tween_callback(func() -> void:
		if visible and not _is_closing:
			command_input.grab_focus()
	)


func _animate_close(succeeded: bool) -> void:
	_kill_tween()
	_is_closing = true
	command_input.editable = false
	command_input.release_focus()

	_tween = create_tween().set_parallel(true)
	_tween.tween_property(laptop_frame, "position:y", _rest_y + SLIDE_OFFSET_Y, CLOSE_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween.tween_property(laptop_frame, "modulate:a", 0.0, CLOSE_DURATION)
	_tween.chain().tween_callback(func() -> void:
		visible = false
		_is_closing = false
		laptop_frame.position.y = _rest_y
		laptop_frame.modulate.a = 1.0
		if succeeded:
			attack_succeeded.emit()
		else:
			attack_failed.emit()
	)


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
