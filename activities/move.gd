extends Activity

class_name Move

func execute() -> void:
	var char = user
	char.change_stat("current_mp", char.get_stat("max_mp"))
	SignalBus.refresh_reachable_tiles.emit()
