extends Resource
class_name ActivityVariant

@export var activity: Activity
@export var modifiers: Array[Modifier] = []

func pre_execute(user: Entity) -> Activity:
	var instance = activity.duplicate(true)
	
	instance.user = user
	
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

		var pre_ctx = instance._build_context()
		instance.pre_execution_bundle_modify(pre_ctx)

	instance.pre_execution_modified = true

	return instance

func produce(user: Entity) -> Activity:
	var instance = activity.duplicate(true)
	
	instance.user = user
	
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

	return instance

func execute(user: Entity, targets: Array[Vector3i] = []) -> void:
	var instance = produce(user)
	if targets:
		instance.target_points.append_array(targets)

	instance.execute()
