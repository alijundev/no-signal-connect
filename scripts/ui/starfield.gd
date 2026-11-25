class_name Starfield
extends ColorRect
## Latar berbintang. Hanya meneruskan ukuran layar ke shader.


func _ready() -> void:
	resized.connect(_update_resolution)
	_update_resolution()


func _update_resolution() -> void:
	var mat := material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("resolution", size)
