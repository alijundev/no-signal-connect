extends Area2D

@onready var warning_label: Label= $WarningLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	warning_label.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D):
	if body is BasePlayer:
		if GameBridge.is_signal_active:
			GameBridge.completed_stage()
		else:
			warning_label.visible = true

func _on_body_exited(body: Node2D):
	if body is BasePlayer:
		warning_label.visible = false
