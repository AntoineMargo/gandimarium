extends Effect
class_name AreaConditionGeneralEffect

@export var condition: AreaCondition = null

func apply(_source, _target, _degree: int = 2) -> void:
	pass

func apply_context(ctx: ActivityContext) -> void:
	var sm = Global.state_manager
	var current_map_state = sm.get_map_state(sm.current_map_id)
	var new_condition_uid = sm.next_uid(Enums.UIDType.CONDITION)
	var instance = condition.duplicate(true)
	instance.uid = new_condition_uid
	current_map_state.area_conditions[new_condition_uid] = instance
	instance.initialize(ctx)

	#ctx.created_conditions.append(instance)
	#ctx.target.toggle_condition(ctx) # makes no sense as the target is the map state
