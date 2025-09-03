extends Activity

class_name Move

func execute(user: Node, context: Dictionary) -> void:
	var char = user.data
	char.movement_points_left += char.movement_points
	SignalBus.refresh_reachable_tiles.emit()
