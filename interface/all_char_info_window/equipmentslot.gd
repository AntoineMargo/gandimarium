extends Label

@export var slot: Enums.EquipmentSlot

func _can_drop_data(_pos: Vector2, data) -> bool:
	var character: Creature = Global.focus_char
	var slot_type: Enums.SlotType = character.data.equipment.SLOT_TO_TYPE[slot]

	var item: Item = null
	if data is ItemContainer:
		item = data.item
	elif data is Item:
		item = data

	if item == null:
		return false

	if slot_type == Enums.SlotType.NONE:
		return true

	if item.slot_type == slot_type:
		return true
	else:
		return false

func _drop_data(_position: Vector2, data) -> void:
	var character: Creature = Global.focus_char
	
	var container: ItemContainer = null
	if data is ItemContainer:
		container = data
	elif data is Item:
		container = ItemContainer.new(data, 1)
	
	if container == null or container.item == null:
		return
	
	if not character.consume_ap(1):
		character.data.inventory.add_container(container)
		return

	var equip_container: ItemContainer = container
	if container.amount > 1:
		container.amount -= 1
		character.data.inventory.add_container(container)
		equip_container = ItemContainer.new(container.item, 1)
	
	var old_container: ItemContainer = get_item_from_slot()
	
	if old_container and old_container.item:
		if not old_container.item.can_be_removed:
			character.data.inventory.add_container(equip_container)
		else:
			old_container = character.unequip_slot(slot)
			character.data.inventory.add_container(old_container)
			character.equip_item_in_slot(equip_container, slot)
	else:
		character.equip_item_in_slot(equip_container, slot)

	Global.ui_manager.drag_in_progress = false
	Global.ui_manager.drag_was_dropped = true
	
	SignalBus.update_inventory.emit()
	SignalBus.update_container.emit()
	SignalBus.update_ui_for_char.emit()

func _get_drag_data(_at_position: Vector2) -> ItemContainer:
	var um = Global.ui_manager
	
	var container: ItemContainer = get_item_from_slot()
	if not container or not container.item or not container.item.can_be_removed:
		return null

	um.drag_in_progress = true
	um.drag_was_dropped = false
	um.last_dragged_item = container

	var preview: Label = Label.new()
	preview.text = container.item.name
	preview.z_index = 3000
	set_drag_preview(preview)
	var removed_container: ItemContainer = Global.selected_char.unequip_slot(slot)
	SignalBus.update_inventory.emit()
	SignalBus.update_container.emit()
	SignalBus.update_ui_for_char.emit()
	return removed_container

func get_item_from_slot() -> ItemContainer:
	return Global.selected_char.data.equipment.get_item_in_slot(slot)
