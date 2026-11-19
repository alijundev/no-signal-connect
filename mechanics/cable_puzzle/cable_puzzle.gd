extends CanvasLayer

signal puzzle_solved

var current_step: int = 1
var total_step: int = 4

@onready var status_label: Label = $PanelContainer/VBoxContainer/StatusLabel
@onready var close_button: Button = $PanelContainer/VBoxContainer/CloseButton

@onready var port1: Button = $PanelContainer/VBoxContainer/ButtonRow/Port1
@onready var port2: Button = $PanelContainer/VBoxContainer/ButtonRow/Port2
@onready var port3: Button = $PanelContainer/VBoxContainer/ButtonRow/Port3
@onready var port4: Button = $PanelContainer/VBoxContainer/ButtonRow/Port4

func _ready() -> void:
	visible = false
	port1.pressed.connect(_on_port_pressed.bind(2, port1))
	port2.pressed.connect(_on_port_pressed.bind(4, port2))
	port3.pressed.connect(_on_port_pressed.bind(1, port3))
	port4.pressed.connect(_on_port_pressed.bind(3, port4))
	close_button.pressed.connect(close_puzzle)

func _on_port_pressed(port: int, ref: Button):
	if port == current_step:
		print("Correct")
		ref.disabled = true
		ref.modulate = Color.GREEN
		current_step += 1
		if current_step > total_step:
			puzzle_solved.emit()
			visible = false
	else:
		reset_puzzle()
		status_label.text = "Urutan salah, coba lagi!"

func reset_puzzle():
	current_step = 1
	var ports_button: Array[Button] = [port1, port2, port3, port4]
	for port in ports_button:
		port.disabled = false
		port.modulate = Color.WHITE
	status_label.text = "Sambungkan Port: 1 -> 2 -> 3 -> 4"

func open_puzzle():
	reset_puzzle()
	visible = true
	

func close_puzzle():
	visible = false
