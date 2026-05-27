extends Resource
class_name ActivityVariant

@export var activity: Activity
@export var modifiers: Array[Modifier] = []

func pre_execute(user: Entity) -> Activity:
	var instance: Activity = null
	if activity is DerivedActivity:
		instance = activity.pre_execute(user)
	else:
		instance = activity.duplicate(true)

	var instance_modifiers = instance.modifiers
	instance.user = user
	
	if modifiers:
		for modifier in modifiers:
			instance_modifiers.append(modifier)

		var pre_ctx = instance._build_context()
		instance.compute_spell_reach() # Could be after pre_execution_bundle_modify()
		instance.pre_execution_bundle_modify(pre_ctx)
		
		for i in range(instance_modifiers.size() - 1, -1, -1):
			if instance_modifiers[i].stage == Enums.ActivityStage.PRE_EXECUTION:
				instance_modifiers.remove_at(i)

	return instance

func produce(user: Entity) -> Activity:
	var instance = activity.duplicate(true)
	
	instance.user = user
	
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

	instance.compute_spell_reach()

	return instance

func execute(user: Entity, targets: Array[Vector3i] = []) -> void:
	var instance = produce(user)
	if targets:
		instance.target_points.append_array(targets)

	instance.execute()
