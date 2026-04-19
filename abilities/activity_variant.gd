extends Resource
class_name ActivityVariant

@export var activity: Activity
@export var modifiers: Array[ActivityModifier] = []

func produce(user: Entity) -> Activity:
	var instance = activity.duplicate(true)
	
	instance.user = user
	
	if modifiers:
		for modifier in modifiers:
			if modifier is BeforeModifier:
				modifier.modify_activity(instance)
			else:
				instance.modifiers.append(modifier)

	return instance

func execute(user: Entity, targets: Array[Vector3i] = []) -> void:
	var instance = activity.duplicate(true)

	instance.user = user

	if modifiers:
		for modifier in modifiers:
			if modifier is BeforeModifier:
				modifier.modify_activity(instance)
			else:
				instance.modifiers.append(modifier)

	if targets:
		instance.target_points.append_array(targets)

	instance.execute()
