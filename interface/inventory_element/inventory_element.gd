extends HBoxContainer

var items_interface = null
var index: int = -1
var item_container: ItemContainer = null
var item: Item:
	get:
		return item_container.item if item_container else null
	set(val):
		if item_container:
			item_container.item = val
		else:
			item_container = ItemContainer.new(val, 1)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed \
	and event.double_click:
		_on_double_clicked()


func _on_double_clicked() -> void:
	if item == null:
		return

	print("Double clicked:", item.name)
	if item is Food:
		Global.selected_char.eat_food(item as Food)


func remove_n_of_item(amount: int) -> ItemContainer:
	var retrieved_container: ItemContainer = null
	if index != -1:
		if items_interface == Enums.ItemsList.INVENTORY:
			retrieved_container = Global.selected_char.data.inventory.remove_item_at_index(index, amount)
			SignalBus.update_inventory.emit()
		elif items_interface == Enums.ItemsList.CONTAINER:
			retrieved_container = Global.game_session.container_window.current_container.inventory.remove_item_at_index(index, amount)
			SignalBus.update_container.emit()
	return retrieved_container


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_container == null or item_container.item == null:
		return null

	var current_amount: int = item_container.amount
	var amount_to_take: int = 1
	if Input.is_key_pressed(KEY_CTRL):
		amount_to_take = mini(5, current_amount)  # prevent over-removal
	if Input.is_key_pressed(KEY_SHIFT):
		amount_to_take = current_amount  # prevent over-removal
	if items_interface != null:
		Global.ui_manager.window_dragged_from = items_interface
	
	var preview: Label = Label.new()
	preview.text = item_container.item.name
	preview.custom_minimum_size = Vector2(100, 20)  # Adjust size as needed
	preview.set_anchors_preset(Control.PRESET_CENTER)
	preview.modulate = Color(1, 1, 1, 1)
	preview.z_index = 200
	set_drag_preview(preview)

	var retrieved_container: ItemContainer = remove_n_of_item(amount_to_take)

	Global.ui_manager.drag_in_progress = true
	Global.ui_manager.drag_was_dropped = false
	Global.ui_manager.last_dragged_item = retrieved_container

	return retrieved_container


func initialize() -> void:
	if item_container and item_container.item:
		$NameLabel.text = item_container.item.name
		$CountLabel.text = "%d" % [item_container.amount]
		if item_container.item.icon:
			$IconRect.texture = item_container.item.icon
	else:
		$NameLabel.text = "Empty"
		$CountLabel.text = ""
