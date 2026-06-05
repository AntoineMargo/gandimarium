extends Effect
## Must be linked to a condition.
class_name CreatePropEffect

@export var prop: PackedScene = null

func apply_context(ctx: Context) -> bool:
	var prop_instance: Prop = null
	if ctx.target is Vector3i:
		prop_instance = Global.world_manager.spawn_prop(prop, ctx.target)
		ctx.created_props.append(prop_instance)
		if ctx is ActivityContext and ctx.condition:
			ctx.condition.linked_props.append(prop_instance)
		if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
			for condition in ctx.shared_context.created_conditions:
				condition.linked_props.append(prop_instance)
		print("Prop added!")
	else:
		push_error("Prop couldn't be added: target is not Vector3i.")
	return true
