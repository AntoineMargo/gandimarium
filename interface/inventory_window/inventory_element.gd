extends Panel

var index: int = -1
var item: Item:
	set(value):
		item = value
		$Label.text = item.name if item else "Empty"

func _get_drag_data(at_position):
	print("index of item: ", index)
	
	var preview = Label.new()
	preview.text = item.name
	preview.custom_minimum_size = Vector2(100, 20)  # Adjust size as needed
	preview.set_anchors_preset(Control.PRESET_CENTER)
	preview.modulate = Color(1, 1, 1, 1)
	preview.z_index = 3000
	set_drag_preview(preview)

	if index != -1:
		Global.focus_char.data.get_inventory().remove_at(index)
	
	SignalBus.update_inventory.emit()
	
	Global.ui_manager.drag_in_progress = true
	Global.ui_manager.drag_was_dropped = false
	Global.ui_manager.last_dragged_item = item
	
	return item
