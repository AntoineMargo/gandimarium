extends Effect
## Must be linked to a condition.
class_name CreatePropEffect

@export var prop: PackedScene = null

func apply_context(ctx: Context) -> bool:
	var prop_instance: Prop = null
	if ctx.target is Vector3i:
		prop_instance = Global.world_manager.spawn_prop(prop, ctx.target)
		if prop_instance.has_method("setup"):
			prop_instance.setup(ctx)
		ctx.created_props.append(prop_instance)
		if ctx is ActivityContext and ctx.condition:
			prop_instance.linked_condition = ctx.condition
			ctx.condition.linked_props.append(prop_instance)
		if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
			for condition in ctx.shared_context.created_conditions:
				prop_instance.linked_condition = condition
				if prop_instance not in condition.linked_props:
					condition.linked_props.append(prop_instance)
		return true
	return false
