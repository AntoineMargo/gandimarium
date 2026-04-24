extends Activity
class_name DerivedActivity

@export var get_selected_weapon_attack: bool = false
@export var base_activity_variant: ActivityVariant = null

func pre_execute() -> Activity:
	var instance: Activity = null
	if get_selected_weapon_attack:
		instance = user.get_selected_weapon_activity()
	else:
		instance = base_activity_variant.produce(user)
	
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

		var pre_ctx = instance._build_context()
		instance.pre_execution_bundle_modify(pre_ctx)

	instance.pre_execution_modified = true

	return instance

func produce() -> Activity:
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
		instance = produce()
		
	if modifiers:
		for modifier in modifiers:
			instance.modifiers.append(modifier)

	instance.execute()
