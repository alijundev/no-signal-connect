class_name ColorMemoryPuzzle
extends CanvasLayer

signal puzzle_solved

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@export var round_lengths: PackedInt32Array = PackedInt32Array([3, 4, 5])
@export var flash_duration: float = 0.4
@export var gap_duration: float = 0.18

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/VBoxContainer/TitleLabel
@onready var status_label: Label = $PanelContainer/VBoxContainer/StatusLabel
@onready var red_button: Button = $PanelContainer/VBoxContainer/ColorGrid/RedButton
@onready var blue_button: Button = $PanelContainer/VBoxContainer/ColorGrid/BlueButton
@onready var green_button: Button = $PanelContainer/VBoxContainer/ColorGrid/GreenButton
@onready var yellow_button: Button = $PanelContainer/VBoxContainer/ColorGrid/YellowButton
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

var _color_buttons: Array[Button] = []
var _idle_styles: Array[StyleBoxFlat] = []
var _lit_styles: Array[StyleBoxFlat] = []
var _pitches: Array[float] = [0.85, 1.0, 1.18, 1.35]

var _sequence: Array[int] = []
var _round_index: int = 0
var _input_index: int = 0
var _is_showing_sequence: bool = false
var _playback_token: int = 0

func _ready() -> void:
	visible = false
	_color_buttons = [red_button, blue_button, green_button, yellow_button]
	_apply_retro_style()
	for i: int in _color_buttons.size():
		_color_buttons[i].pressed.connect(_on_color_pressed.bind(i))
	close_button.pressed.connect(close_puzzle)

func _apply_retro_style() -> void:
	var font: Font = RetroTheme.load_font()
	panel.add_theme_stylebox_override("panel", RetroTheme.box(RetroTheme.COL_PANEL, RetroTheme.COL_CYAN, 3, 24, 20))

	if font != null:
		title_label.add_theme_font_override("font", font)
		status_label.add_theme_font_override("font", font)
	title_label.add_theme_font_size_override("font_size", 11)
	title_label.add_theme_color_override("font_color", RetroTheme.COL_CYAN)
	title_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	title_label.add_theme_constant_override("outline_size", 2)

	status_label.add_theme_font_size_override("font_size", 10)
	status_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	status_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	status_label.add_theme_constant_override("outline_size", 2)

	var base_colors: Array[Color] = [
		Color("#b83242"),
		Color("#3568c9"),
		Color("#2e9c49"),
		Color("#c4ad1d"),
	]
	_idle_styles.clear()
	_lit_styles.clear()

	for i: int in _color_buttons.size():
		var btn: Button = _color_buttons[i]
		var idle_col: Color = base_colors[i].darkened(0.28)
		var lit_col: Color = base_colors[i].lightened(0.35)
		var idle_sb: StyleBoxFlat = RetroTheme.box(idle_col, RetroTheme.COL_OUTLINE, 3, 16, 12)
		var lit_sb: StyleBoxFlat = RetroTheme.box(lit_col, RetroTheme.COL_TEXT, 3, 16, 12)
		_idle_styles.append(idle_sb)
		_lit_styles.append(lit_sb)

		if font != null:
			btn.add_theme_font_override("font", font)
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
		btn.add_theme_color_override("font_hover_color", RetroTheme.COL_TEXT)
		btn.add_theme_color_override("font_disabled_color", RetroTheme.COL_TEXT)
		btn.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
		btn.add_theme_constant_override("outline_size", 2)
		btn.add_theme_stylebox_override("normal", idle_sb)
		btn.add_theme_stylebox_override("hover", idle_sb)
		btn.add_theme_stylebox_override("pressed", lit_sb)
		btn.add_theme_stylebox_override("disabled", idle_sb)
		btn.custom_minimum_size = Vector2(140, 48)

	if font != null:
		close_button.add_theme_font_override("font", font)
	close_button.add_theme_font_size_override("font_size", 11)
	close_button.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
	close_button.add_theme_color_override("font_hover_color", RetroTheme.COL_ACCENT)
	close_button.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	close_button.add_theme_constant_override("outline_size", 2)
	close_button.add_theme_stylebox_override("normal", RetroTheme.pill_style(RetroTheme.COL_EXTRUDE))
	close_button.add_theme_stylebox_override("hover", RetroTheme.pill_style(RetroTheme.COL_PRIMARY))
	close_button.add_theme_stylebox_override("pressed", RetroTheme.pill_style(RetroTheme.COL_ALLEN))
	close_button.custom_minimum_size = Vector2(140, 38)

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_puzzle()
		get_viewport().set_input_as_handled()

func open_puzzle() -> void:
	_round_index = 0
	visible = true
	_start_current_round(true)

func close_puzzle() -> void:
	_playback_token += 1
	_is_showing_sequence = false
	_reset_button_highlights()
	visible = false

func _start_current_round(generate_new: bool = true) -> void:
	if round_lengths.is_empty():
		round_lengths = PackedInt32Array([3, 4, 5])
	var seq_len: int = round_lengths[clampi(_round_index, 0, round_lengths.size() - 1)]
	if generate_new:
		_sequence.clear()
		for _i: int in seq_len:
			_sequence.append(randi() % _color_buttons.size())
	_input_index = 0
	_play_sequence()

func _play_sequence() -> void:
	_playback_token += 1
	var token: int = _playback_token
	_is_showing_sequence = true
	_set_color_buttons_disabled(true)
	_reset_button_highlights()
	status_label.add_theme_color_override("font_color", RetroTheme.COL_ACCENT)
	status_label.text = "Perhatikan pola! (Ronde %d/%d)" % [_round_index + 1, round_lengths.size()]

	await get_tree().create_timer(0.5).timeout
	if not _is_playback_valid(token):
		return

	for color_idx: int in _sequence:
		_set_button_lit(color_idx, true)
		Game.play_sfx("move", _pitches[color_idx])
		await get_tree().create_timer(flash_duration).timeout
		if not _is_playback_valid(token):
			return
		_set_button_lit(color_idx, false)
		await get_tree().create_timer(gap_duration).timeout
		if not _is_playback_valid(token):
			return

	_is_showing_sequence = false
	_input_index = 0
	_set_color_buttons_disabled(false)
	status_label.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
	status_label.text = "Giliranmu! (%d/%d)" % [0, _sequence.size()]

func _is_playback_valid(token: int) -> bool:
	return token == _playback_token and is_inside_tree() and visible

func _on_color_pressed(color_idx: int) -> void:
	if _is_showing_sequence or not visible:
		return

	_flash_pressed_button(color_idx)
	Game.play_sfx("move", _pitches[color_idx])

	if color_idx == _sequence[_input_index]:
		_input_index += 1
		if _input_index >= _sequence.size():
			_round_index += 1
			if _round_index >= round_lengths.size():
				_finish_puzzle()
			else:
				_is_showing_sequence = true
				_set_color_buttons_disabled(true)
				Game.play_sfx("select")
				status_label.add_theme_color_override("font_color", Color("#76ff7a"))
				status_label.text = "Benar! Lanjut ronde %d..." % (_round_index + 1)
				var token: int = _playback_token
				await get_tree().create_timer(0.6).timeout
				if _is_playback_valid(token):
					_start_current_round(true)
		else:
			status_label.add_theme_color_override("font_color", Color("#76ff7a"))
			status_label.text = "Cocok! (%d/%d)" % [_input_index, _sequence.size()]
	else:
		_is_showing_sequence = true
		_set_color_buttons_disabled(true)
		Game.play_sfx("back")
		status_label.add_theme_color_override("font_color", Color("#ff6b6b"))
		status_label.text = "Salah! Perhatikan ulang polanya..."
		var token: int = _playback_token
		await get_tree().create_timer(0.8).timeout
		if _is_playback_valid(token):
			_start_current_round(false)

func _finish_puzzle() -> void:
	_playback_token += 1
	_is_showing_sequence = true
	_set_color_buttons_disabled(true)
	Game.play_sfx("select")
	status_label.add_theme_color_override("font_color", Color("#76ff7a"))
	status_label.text = "Sinyal Menara Terhubung!"
	await get_tree().create_timer(0.35).timeout
	if is_inside_tree() and visible:
		visible = false
		puzzle_solved.emit()

func _flash_pressed_button(color_idx: int) -> void:
	var token: int = _playback_token
	_set_button_lit(color_idx, true)
	await get_tree().create_timer(0.15).timeout
	if is_inside_tree() and token == _playback_token and not _is_showing_sequence:
		_set_button_lit(color_idx, false)

func _set_button_lit(color_idx: int, lit: bool) -> void:
	var btn: Button = _color_buttons[color_idx]
	var sb: StyleBoxFlat = _lit_styles[color_idx] if lit else _idle_styles[color_idx]
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("disabled", sb)

func _reset_button_highlights() -> void:
	for i: int in _color_buttons.size():
		_set_button_lit(i, false)

func _set_color_buttons_disabled(disabled_state: bool) -> void:
	for btn: Button in _color_buttons:
		btn.disabled = disabled_state
