extends Control

var surface_levels: Array[String] = [
	"res://levels/stage_01/surface_01.tscn",
	"res://levels/stage_02/surface_02.tscn"
]
var underground_levels: Array[String] = [
	"res://levels/stage_01/underground_01.tscn",
	"res://levels/stage_02/underground_02.tscn"
]

@onready var top_viewport: SubViewport = $VBoxContainer/TopContainer/TopViewport
@onready var bottom_viewport: SubViewport = $VBoxContainer/BottomContainer/BottomViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	GameBridge.stage_changed.connect(_load_stage)

func _load_stage(index: int) -> void:
	if top_viewport.get_child_count() > 0 :
		top_viewport.get_child(0).queue_free()
	
	if bottom_viewport.get_child_count() > 0 :
		bottom_viewport.get_child(0).queue_free()
	
	var new_top_scene: Node2D = load(surface_levels[index]).instantiate()
	var new_bottom_scene: Node2D = load(underground_levels[index]).instantiate()
	
	top_viewport.add_child(new_top_scene)
	bottom_viewport.add_child(new_bottom_scene)
	
	
