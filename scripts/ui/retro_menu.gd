class_name RetroMenu
extends VBoxContainer
## Daftar tombol vertikal dengan aturan seleksi tunggal:
## - Tidak ada item yang menyala sampai mouse menyentuh item / tombol panah ditekan.
## - Hover mouse = item terpilih; mouse keluar = highlight hilang.
## - Navigasi keyboard / gamepad berputar (atas dari item pertama -> item terakhir).

var _keyboard_mode := false


func _ready() -> void:
	var items := _items()
	if items.size() > 1:
		var first := items[0]
		var last := items[items.size() - 1]
		first.focus_neighbor_top = first.get_path_to(last)
		last.focus_neighbor_bottom = last.get_path_to(first)
	for item in items:
		item.mouse_exited.connect(_on_item_mouse_exited.bind(item))


func _items() -> Array[Button]:
	var out: Array[Button] = []
	for child in get_children():
		if child is Button and child.visible:
			out.append(child as Button)
	return out


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventMouseMotion:
		if _keyboard_mode:
			_keyboard_mode = false
			_sync_focus_to_mouse()
		return

	var go_up := event.is_action_pressed("ui_up") or event.is_action_pressed("ui_focus_prev")
	var go_down := event.is_action_pressed("ui_down") or event.is_action_pressed("ui_focus_next")
	if not (go_up or go_down):
		return

	_keyboard_mode = true
	# Belum ada yang terpilih -> mulai dari item pertama (atau terakhir kalau tekan atas).
	if get_viewport().gui_get_focus_owner() == null:
		var items := _items()
		if not items.is_empty():
			items[items.size() - 1 if go_up else 0].grab_focus()
			get_viewport().set_input_as_handled()


func _sync_focus_to_mouse() -> void:
	for item in _items():
		if Rect2(Vector2.ZERO, item.size).has_point(item.get_local_mouse_position()):
			item.grab_focus()
			return
	var focused := get_viewport().gui_get_focus_owner()
	if focused != null and focused is Button and is_ancestor_of(focused):
		focused.release_focus()


func _on_item_mouse_exited(item: Button) -> void:
	if not _keyboard_mode and item.has_focus():
		item.release_focus()
