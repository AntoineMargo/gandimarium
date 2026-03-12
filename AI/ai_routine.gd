extends Resource
class_name NPCRoutine

@export var entries: Array[RoutineEntry]

func get_activity(hour: int) -> RoutineEntry:
	var current: RoutineEntry = entries[0]

	for e in entries:
		if hour >= e.start_hour:
			current = e
		else:
			break

	return current
