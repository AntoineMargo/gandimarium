extends Label

@export var slot_name: String

func _can_drop_data(_pos, data):
	if self.slot_name == "body":
		return data is Armour
	elif self.slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		return data is Weapon
	else:
		return false

func _drop_data(position, item):
	if not (item is Item):
		return

	var char = Global.selected_char.char_data
	
	char.equip_item(slot_name, item)

	if item is Weapon:
		if char.active_set == 1 and slot_name in ["set1_left_hand", "set1_right_hand"]:
			if char.set1_left_hand:
				char.active_attack1 = char.set1_left_hand.attack_type[0]
			if char.set1_right_hand:
				char.active_attack2 = char.set1_right_hand.attack_type[0]
		elif char.active_set == 2 and slot_name in ["set2_left_hand", "set2_right_hand"]:
			if char.set2_left_hand:
				char.active_attack1 = char.set2_left_hand.attack_type[0]
			if char.set2_right_hand:
				char.active_attack2 = char.set2_right_hand.attack_type[0]

	Global.ui_manager.drag_in_progress = false
	Global.ui_manager.drag_was_dropped = true
	
	SignalBus.update_inventory.emit()
	SignalBus.update_ui_for_char.emit()

func _get_drag_data(at_position):
	var um = Global.ui_manager
	var item = Global.selected_char.char_data.get(slot_name)
	if item == null:
		return

	um.drag_in_progress = true
	um.drag_was_dropped = false
	um.last_dragged_item = item

	var preview = Label.new()
	preview.text = item.name
	preview.z_index = 3000
	set_drag_preview(preview)
	Global.selected_char.char_data.unequip_slot(slot_name)
	#if slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		#Global.selected_char.char_data.equip_item(slot_name, Global.fist)
	SignalBus.update_inventory.emit()
	return item
