class_name WorldBackdrop
extends CanvasLayer

enum Kind {
	SURFACE_DAY,
	SURFACE_DUSK,
	UNDERGROUND,
}

@export var kind: Kind = Kind.SURFACE_DAY

var _root: Control

func _ready() -> void:
	layer = -10
	_build_backdrop()

func set_kind(new_kind: Kind) -> void:
	kind = new_kind
	_build_backdrop()

func _build_backdrop() -> void:
	if _root != null:
		_root.queue_free()
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	match kind:
		Kind.SURFACE_DAY:
			_build_surface(
				Color("#5c94fc"),
				Color("#7eb0ff"),
				Color("#b6d6ff"),
				Color("#4a668a"),
				Color("#354963"),
				Color("#fff6b3")
			)
		Kind.SURFACE_DUSK:
			_build_surface(
				Color("#22264a"),
				Color("#49386b"),
				Color("#8a5473"),
				Color("#23243b"),
				Color("#171829"),
				Color("#ffd180")
			)
		Kind.UNDERGROUND:
			_build_underground()

func _build_surface(top_col: Color, mid_col: Color, low_col: Color, far_bld: Color, near_bld: Color, sun_col: Color) -> void:
	_add_band(0.0, 0.38, top_col)
	_add_band(0.38, 0.72, mid_col)
	_add_band(0.72, 1.0, low_col)

	# Sun / Moon glow
	var orb := ColorRect.new()
	orb.color = sun_col
	orb.position = Vector2(960.0, 68.0)
	orb.size = Vector2(64.0, 64.0)
	orb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(orb)

	# Distant city skyline silhouettes
	var heights: Array[float] = [180, 260, 140, 310, 210, 160, 280, 190, 240, 150, 290, 175]
	var x_pos: float = 0.0
	for i: int in heights.size():
		var w: float = 110.0
		var h: float = heights[i]
		var col: Color = far_bld if i % 2 == 0 else near_bld
		var bld := ColorRect.new()
		bld.color = col
		bld.position = Vector2(x_pos, 520.0 - h)
		bld.size = Vector2(w - 6.0, h + 200.0)
		bld.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_root.add_child(bld)
		x_pos += w

func _build_underground() -> void:
	_add_band(0.0, 0.45, Color("#111319"))
	_add_band(0.45, 0.85, Color("#191c24"))
	_add_band(0.85, 1.0, Color("#12141a"))

	# Structural tunnel pillars & industrial warning trim
	for i: int in 6:
		var px: float = 90.0 + float(i) * 215.0
		var pillar := ColorRect.new()
		pillar.color = Color("#222631")
		pillar.position = Vector2(px, 0.0)
		pillar.size = Vector2(36.0, 720.0)
		pillar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_root.add_child(pillar)

		var pipe := ColorRect.new()
		pipe.color = Color("#2d3340")
		pipe.position = Vector2(px + 10.0, 0.0)
		pipe.size = Vector2(8.0, 720.0)
		pipe.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_root.add_child(pipe)

	var top_beam := ColorRect.new()
	top_beam.color = Color("#252a36")
	top_beam.position = Vector2(0.0, 0.0)
	top_beam.size = Vector2(1280.0, 44.0)
	top_beam.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(top_beam)

func _add_band(top_ratio: float, bottom_ratio: float, col: Color) -> void:
	var band := ColorRect.new()
	band.color = col
	band.anchor_left = 0.0
	band.anchor_right = 1.0
	band.anchor_top = top_ratio
	band.anchor_bottom = bottom_ratio
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(band)
