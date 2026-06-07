extends HBoxContainer

var items_interface = null
var index: int = -1
var item: Item

func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed \
	and event.double_click:
		_on_double_clicked()

func _on_double_clicked():
	if item == null:
		return

	print("Double clicked:", item.name)
	if item is Food:
		Global.selected_char.eat_food(item)

func remove_n_of_item(amount) -> Item:
	var retrieved_item = null
	if index != -1:
		if items_interface == Enums.ItemsList.INVENTORY:
			retrieved_item = Global.selected_char.data.inventory.remove_item_at_index(index, amount)
			SignalBus.update_inventory.emit()
		elif items_interface == Enums.ItemsList.CONTAINER:
			retrieved_item = Global.container_window.current_container.inventory.remove_item_at_index(index, amount)
			SignalBus.update_container.emit()
	return retrieved_item

func _get_drag_data(_at_position):
	var amount_to_take: int = 1
	if Input.is_key_pressed(KEY_CTRL):
		amount_to_take = min(5, item.count)  # prevent over-removal
	if Input.is_key_pressed(KEY_SHIFT):
		amount_to_take = item.count  # prevent over-removal
	if items_interface:
		Global.ui_manager.window_dragged_from = items_interface
	
	var preview = Label.new()
	preview.text = item.name
	preview.custom_minimum_size = Vector2(100, 20)  # Adjust size as needed
	preview.set_anchors_preset(Control.PRESET_CENTER)
	preview.modulate = Color(1, 1, 1, 1)
	preview.z_index = 3000
	set_drag_preview(preview)

	var retrieved_item = remove_n_of_item(amount_to_take)

	Global.ui_manager.drag_in_progress = true
	Global.ui_manager.drag_was_dropped = false
	Global.ui_manager.last_dragged_item = retrieved_item

	return retrieved_item

func initialize():
	$NameLabel.text = item.name if item else "Empty"
	$CountLabel.text = "%d" % [item.count]

#func _ready() -> void:
	#pass
