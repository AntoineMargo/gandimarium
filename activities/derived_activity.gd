extends Activity
class_name DerivedActivity

@export var get_selected_weapon_attack: bool = false
@export var base_activity_variant: ActivityVariant = null

@warning_ignore("shadowed_variable_base_class")
func pre_execute(user) -> Activity:
	var instance: Activity = null
	if get_selected_weapon_attack:
		var selected_weapon_activity = user.get_selected_weapon_activity()
		instance = selected_weapon_activity.duplicate(true)
		instance.weapon = selected_weapon_activity.weapon
	else:
		instance = base_activity_variant.produce(user)
	
	instance.name = name
	instance.description = description
	instance.icon = icon
	instance.user = user
	
	var instance_modifiers = instance.modifiers
	
	if modifiers:
		for modifier in modifiers:
			instance_modifiers.append(modifier)

		var pre_ctx = instance._build_context()
		instance.pre_execution_bundle_modify(pre_ctx)

		for i in range(instance_modifiers.size() - 1, -1, -1):
			if instance_modifiers[i].stage == Enums.ActivityStage.PRE_EXECUTION:
				instance_modifiers.remove_at(i)

	return instance

@warning_ignore("shadowed_variable_base_class")
func produce(user) -> Activity:
	var instance: Activity = null
	if get_selected_weapon_attack:
		instance = user.get_selected_weapon_activity()
	else:
		instance = base_activity_variant.produce(user)
	
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

	return instance

func execute() -> void:
	var instance: Activity = null
	if get_selected_weapon_attack:
		instance = user.get_selected_weapon_activity()
	else:
		instance = produce(user)
		
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

	instance.execute()
