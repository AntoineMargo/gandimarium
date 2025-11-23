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

	var char = Global.focus_char.data

	var old_item = get_item_from_slot()
	if old_item:
		char.add_to_inventory(old_item)
	char.equip_item(slot_name, item)

	Global.ui_manager.drag_in_progress = false
	Global.ui_manager.drag_was_dropped = true
	
	SignalBus.update_inventory.emit()
	SignalBus.update_ui_for_char.emit()

func _get_drag_data(at_position):
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
	Global.focus_char.data.unequip_slot(slot_name)
	SignalBus.update_inventory.emit()
	SignalBus.update_ui_for_char.emit()
	return item

func get_item_from_slot() -> Item:
	var item = null;
	if self.slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		item = Global.focus_char.data.get_weapon_slot(slot_name)
		if item:
			print("Equipment slot weapon name: ", item.name)
	else:
		item = Global.focus_char.data.get_slot(slot_name)
	return item

#extends Label
#
#@export var slot_name: String
#
#func _can_drop_data(_pos, data):
	#if self.slot_name == "body":
		#return data is Armour
	#elif self.slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		#return data is Weapon
	#else:
		#return false
#
#func _drop_data(position, item):
	#if not (item is Item):
		#return
#
	#var char = Global.focus_char.data
	#
	#char.equip_item(slot_name, item)
#
	#Global.ui_manager.drag_in_progress = false
	#Global.ui_manager.drag_was_dropped = true
	#
	#SignalBus.update_inventory.emit()
	#SignalBus.update_ui_for_char.emit()
#
#func _get_drag_data(at_position):
	#var um = Global.ui_manager
	#var item = null;
	#if self.slot_name in ["set1_left_hand", "set1_right_hand", "set2_left_hand", "set2_right_hand"]:
		#item = Global.focus_char.data.get_weapon_slot(slot_name)
		#if item:
			#print("Equipment slot weapon name: ", item.name)
	#else:
		#item = Global.focus_char.data.get_slot(slot_name)
	#if item == null:
		#return
#
	#um.drag_in_progress = true
	#um.drag_was_dropped = false
	#um.last_dragged_item = item
#
	#var preview = Label.new()
	#preview.text = item.name
	#preview.z_index = 3000
	#set_drag_preview(preview)
	#Global.focus_char.data.unequip_slot(slot_name)
	#SignalBus.update_inventory.emit()
	#SignalBus.update_ui_for_char.emit()
	#return item
