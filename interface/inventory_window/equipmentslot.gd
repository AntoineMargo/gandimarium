extends Label

@export var slot_name: String

func _can_drop_data(_pos, data):
	if self.slot_name == "body":
		return data is Armour
	elif self.slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		return data is Weapon
	else:
		return false

func _drop_data(_position, item):
	if not (item is Item):
		return

	var character = Global.focus_char

	var old_item = get_item_from_slot()
	
	if old_item and not old_item.can_be_removed:
		character.add_to_inventory(item)
	elif old_item and old_item.name != "Fist":
		character.add_to_inventory(old_item)
		character.equip_item(slot_name, item)
	else:
		character.equip_item(slot_name, item)

	#if old_item and old_item.can_be_removed:
		#if old_item and old_item.name != "Fist":
			#character.add_to_inventory(old_item)
		#character.equip_item(slot_name, item)
	#else:
		#character.add_to_inventory(item)

	Global.ui_manager.drag_in_progress = false
	Global.ui_manager.drag_was_dropped = true
	
	SignalBus.update_inventory.emit()
	SignalBus.update_container.emit()
	SignalBus.update_ui_for_char.emit()

func _get_drag_data(_at_position):
	var item = get_item_from_slot()
	if not item:
		return
	var um = Global.ui_manager

	um.drag_in_progress = true
	um.drag_was_dropped = false
	um.last_dragged_item = item

	var preview = Label.new()
	preview.text = item.name
	preview.z_index = 3000
	set_drag_preview(preview)
	Global.focus_char.unequip_slot(slot_name)
	SignalBus.update_inventory.emit()
	SignalBus.update_container.emit()
	SignalBus.update_ui_for_char.emit()
	return item

func get_item_from_slot() -> Item:
	var item = null;
	if self.slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		item = Global.focus_char.get_weapon_slot(slot_name)
		var default = Global.focus_char.data.equipment.default_weapon
		if item and default:
			if item.name == default.name:
				return null
		if item:
			print("Equipment slot weapon name: ", item.name)
	else:
		item = Global.focus_char.get_equipment_slot(slot_name)
	return item
