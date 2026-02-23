extends HBoxContainer

var items_interface = null
var index: int = -1
var item: Item

func _get_drag_data(_at_position):
	print("index of item: ", index)
	if items_interface:
		Global.ui_manager.window_dragged_from = items_interface
	
	var preview = Label.new()
	preview.text = item.name
	preview.custom_minimum_size = Vector2(100, 20)  # Adjust size as needed
	preview.set_anchors_preset(Control.PRESET_CENTER)
	preview.modulate = Color(1, 1, 1, 1)
	preview.z_index = 3000
	set_drag_preview(preview)

	if index != -1:
		if items_interface == Enums.ItemsInterface.INVENTORY:
			Global.selected_char.data.inventory.remove_item_at_index(index)
			SignalBus.update_inventory.emit()
		elif items_interface == Enums.ItemsInterface.CONTAINER:
			Global.container_window.current_container.inventory.remove_item_at_index(index)
			SignalBus.update_container.emit()

	Global.ui_manager.drag_in_progress = true
	Global.ui_manager.drag_was_dropped = false
	Global.ui_manager.last_dragged_item = item

	return item

func initialize():
	$NameLabel.text = item.name if item else "Empty"
	$CountLabel.text = "%d" % [item.count]

#func _ready() -> void:
	#pass
