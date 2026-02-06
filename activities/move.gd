extends Activity

class_name Move

func execute() -> void:
	var char = user
	
	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return

	char.change_stat("current_mp", char.get_stat("max_mp"))
	#user.consume_ap(AP_cost)
	#SignalBus.refresh_reachable_tiles.emit()
	SignalBus.update_ui_for_char.emit()
