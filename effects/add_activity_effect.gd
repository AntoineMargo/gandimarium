extends Effect
class_name AddActivityEffect

@export var activities: Array[ActivityContainer] = []

func apply(_source, target, _degree: int = 2) -> void:
	for activity in activities:
		var new_activity = activity.duplicate()
		if target.has_method("add_activity"):
			target.add_activity(new_activity)
