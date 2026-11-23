extends Effect
## Must be linked to a condition.
class_name CreatePropEffect

@export var prop_id: String = ""


func apply_context(ctx: Context) -> bool:
	if ctx.target is Vector3i:
		var prop_data = Library.get_prop(prop_id)
		var prop: Prop = Global.world_manager.spawn_prop_at_pos_from_data(prop_data, ctx.target, ctx)
		ctx.created_props.append(prop)

		if ctx is ActivityContext and ctx.shared_context:
			ctx.shared_context.created_props.append(prop)

			if !ctx.shared_context.created_conditions.is_empty():
				var condition: Condition = ctx.shared_context.created_conditions.back()
				prop_data.linked_condition = condition
				condition.linked_props.append(prop)

		return true
	return false
