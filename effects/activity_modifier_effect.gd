extends Effect
class_name ActivityModifierEffect

@export var modifier: Modifier = null

func apply_context(ctx: Context) -> bool:
	var instance = modifier.duplicate(true)
	instance.owner = ctx.target
	ctx.target.data.activity_modifiers.append(instance)
	if ctx.condition:
		ctx.condition.linked_modifiers.append(instance)
	if ctx is ActivityContext and ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		for condition in ctx.shared_context.created_conditions:
			condition.linked_modifiers.append(instance)
	return true
