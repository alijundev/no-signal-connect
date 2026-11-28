class_name WorldHint
extends PanelContainer
## Panel petunjuk tutorial bergaya retro di dalam dunia permainan.
## Dapat hilang otomatis setelah pemain mempraktikkan aksi yang diajarkan.

const RetroTheme = preload("res://scripts/ui/retro_theme.gd")

@export_multiline var hint_text: String = ""
@export var accent_color: Color = RetroTheme.COL_ACCENT

@export_group("Auto Dismiss")
@export var tutorial_id: String = ""
@export var active_screen: GameBridge.Screen = GameBridge.Screen.TOP
@export var dismiss_on_actions: PackedStringArray = PackedStringArray()
@export var require_all_actions: bool = false
@export var dismiss_delay: float = 0.5
@export var dismiss_on_signal_active: bool = false
@export var dismiss_on_luna_attack: bool = false
@export var auto_hide_seconds: float = 0.0
@export var start_hidden: bool = false
@export var next_hint: NodePath = NodePath("")

var _label: Label
var _completed_actions: Dictionary = {}
var _dismissed: bool = false
var _dismiss_queued: bool = false
var _elapsed_visible: float = 0.0


func _ready() -> void:
	if not tutorial_id.is_empty() and Game.is_tutorial_done(tutorial_id):
		if not next_hint.is_empty():
			_reveal_next_deferred.call_deferred()
		queue_free()
		return

	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 10

	add_theme_stylebox_override(
		"panel",
		RetroTheme.box(Color(RetroTheme.COL_BG, 0.86), accent_color, 2, 10, 8)
	)

	_label = Label.new()
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.text = hint_text

	var font: Font = RetroTheme.load_font()
	if font != null:
		_label.add_theme_font_override("font", font)
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", RetroTheme.COL_TEXT)
	_label.add_theme_color_override("font_outline_color", RetroTheme.COL_OUTLINE)
	_label.add_theme_constant_override("outline_size", 3)
	_label.add_theme_constant_override("line_spacing", 5)

	add_child(_label)
	reset_size()

	if start_hidden:
		visible = false
		modulate.a = 0.0

	if dismiss_on_signal_active:
		GameBridge.signal_state_changed.connect(_on_signal_state_changed)

	if dismiss_on_luna_attack:
		_connect_luna_attack.call_deferred()


func _connect_luna_attack() -> void:
	var parent_node: Node = get_parent()
	if parent_node == null:
		return
	for child: Node in parent_node.get_children():
		if child is Luna:
			var luna_node: Luna = child as Luna
			if luna_node.laptop_terminal != null:
				luna_node.laptop_terminal.attack_succeeded.connect(_on_luna_attack_succeeded)
			return


func _process(delta: float) -> void:
	if _dismissed or _dismiss_queued or not visible:
		return
	if GameBridge.active_screen != active_screen:
		return

	if not dismiss_on_actions.is_empty():
		for action_name: String in dismiss_on_actions:
			if Input.is_action_just_pressed(action_name):
				_completed_actions[action_name] = true
		if _check_actions_complete():
			_queue_dismiss()
			return

	if auto_hide_seconds > 0.0:
		_elapsed_visible += delta
		if _elapsed_visible >= auto_hide_seconds:
			_queue_dismiss()


func _check_actions_complete() -> bool:
	if require_all_actions:
		for action_name: String in dismiss_on_actions:
			if not _completed_actions.get(action_name, false):
				return false
		return true
	return not _completed_actions.is_empty()


func _on_signal_state_changed(is_active: bool) -> void:
	if is_active:
		_queue_dismiss()


func _on_luna_attack_succeeded() -> void:
	_queue_dismiss()


func _queue_dismiss() -> void:
	if _dismissed or _dismiss_queued:
		return
	_dismiss_queued = true
	if dismiss_delay > 0.0:
		get_tree().create_timer(dismiss_delay).timeout.connect(dismiss)
	else:
		dismiss()


func reveal() -> void:
	if _dismissed:
		return
	visible = true
	modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.35)


func _reveal_next_deferred() -> void:
	var next_node: Node = get_node_or_null(next_hint)
	if next_node is WorldHint:
		(next_node as WorldHint).reveal()


func dismiss() -> void:
	if _dismissed:
		return
	_dismissed = true
	if not tutorial_id.is_empty():
		Game.mark_tutorial_done(tutorial_id)
	if not next_hint.is_empty():
		var next_node: Node = get_node_or_null(next_hint)
		if next_node is WorldHint:
			(next_node as WorldHint).reveal()

	var tw: Tween = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.tween_callback(queue_free)
