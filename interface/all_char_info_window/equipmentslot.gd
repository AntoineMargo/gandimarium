extends Label

@export var slot: Enums.EquipmentSlot

func _can_drop_data(_pos, item):
	var character = Global.focus_char
	var slot_type = character.data.equipment.SLOT_TO_TYPE[slot]

	if slot_type == Enums.SlotType.NONE:
		return true

	if item.slot_type == slot_type:
		return true
	else:
		return false

func _drop_data(_position, item):
	var character = Global.focus_char
	
	if not (item is Item):
		return
	
	var old_item = get_item_from_slot()
	
	if old_item:
		if not old_item.can_be_removed:
			character.data.inventory.add_item(item)
		else:
			old_item = character.unequip_slot(slot)
			character.data.inventory.add_item(old_item)
			character.equip_item_in_slot(item, slot)
	else:
		character.equip_item_in_slot(item, slot)

	Global.ui_manager.drag_in_progress = false
	Global.ui_manager.drag_was_dropped = true
	
	SignalBus.update_inventory.emit()
	SignalBus.update_container.emit()
	SignalBus.update_ui_for_char.emit()

func _get_drag_data(_at_position):
	var um = Global.ui_manager
	
	var item = get_item_from_slot()
	if not item or not item.can_be_removed:
		return

	um.drag_in_progress = true
	um.drag_was_dropped = false
	um.last_dragged_item = item

	var preview = Label.new()
	preview.text = item.name
	preview.z_index = 3000
	set_drag_preview(preview)
	Global.selected_char.unequip_slot(slot)
	SignalBus.update_inventory.emit()
	SignalBus.update_container.emit()
	SignalBus.update_ui_for_char.emit()
	return item

func get_item_from_slot() -> Item:
	return Global.selected_char.data.equipment.get_item_in_slot(slot)
