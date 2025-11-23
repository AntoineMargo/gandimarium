extends Activity

class_name Move

func execute() -> void:
	var char = user.data
	char.current_mp += char.max_mp
	SignalBus.refresh_reachable_tiles.emit()
