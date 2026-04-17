extends Resource
class_name ActivityContainer

@export var activity: Activity
@export var modifiers: Array[ActivityModifier] = []

func execute(targets: Array[Vector3i] = []):
	var instance = activity.duplicate(true)

	for modifier in modifiers:
		instance.modifiers.append(modifier)

	if targets:
		instance.target_points.append_array(targets)

	instance.execute()
