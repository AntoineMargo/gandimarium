extends VBoxContainer

func _can_drop_data(_pos, data):
	return data is Item

func _drop_data(position, data):
	var um = Global.ui_manager
	if data is Item:
		var char = Global.focus_char

		var target_index = 0
		var children = get_children()

		for child in children:
			var child_pos = child.position.y
			var child_height = child.size.y
			if position.y > child_pos + child_height / 2:
				target_index += 1
			else:
				break

		# Clamp target index to valid range
		target_index = clamp(target_index, 0, char.get_inventory().size())

		# Insert it
		char.get_inventory().insert(target_index, data)
		
		print("drag considered successful.")
		um.drag_in_progress = false
		um.drag_was_dropped = true

		SignalBus.update_inventory.emit()
