extends VBoxContainer

func _can_drop_data(_pos: Vector2, data) -> bool:
	return data is Item or data is ItemContainer

func _drop_data(_position: Vector2, data) -> void:
	var um = Global.ui_manager
	if data is Item or data is ItemContainer:
		var character: Creature = Global.focus_char

		var target_index: int = 0
		var children: Array[Node] = get_children()

		for child: Node in children:
			var control_child: Control = child as Control
			if control_child:
				var child_pos: float = control_child.position.y
				var child_height: float = control_child.size.y
				if position.y > child_pos + child_height / 2:
					target_index += 1
				else:
					break

		# Clamp target index to valid range
		target_index = clampi(target_index, 0, character.data.inventory.get_inventory().size())

		# Insert it
		if data is ItemContainer:
			character.data.inventory.add_container_at_index(data, target_index)
		elif data is Item:
			character.data.inventory.add_item_at_index(data, target_index)
		
		print("drag considered successful.")
		um.drag_in_progress = false
		um.drag_was_dropped = true

		SignalBus.update_inventory.emit()
		SignalBus.update_container.emit()
