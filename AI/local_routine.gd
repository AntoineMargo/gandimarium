extends Resource
class_name LocalRoutine

@export var entries: Array[RoutineEntry]

func get_current_entry(hour: int) -> RoutineEntry:
	var current: RoutineEntry = entries[0]

	for entry in entries:
		if hour >= entry.start_hour:
			current = entry
		else:
			break

	return current
