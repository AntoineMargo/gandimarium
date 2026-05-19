extends Effect
class_name CreatePropEffect

@export var prop: PackedScene = null

func apply_context(ctx: Context) -> void:
	var prop_instance: Prop = null
	if ctx.target is Vector3i:
		prop_instance = Global.world_manager.spawn_prop(prop, ctx.target)
		ctx.created_props.append(prop_instance)
		if ctx.condition == null:
			push_error("Props must be created from inside a condition!")
		ctx.condition.linked_props.append(prop_instance)
		print("Prop added!")
	else:
		push_error("Prop couldn't be added: target is not Vector3i.")
