extends Effect
class_name FinalizeAreaConditionsEffect

func apply_context(ctx: ActivityContext) -> void:
	for condition in ctx.shared_context.created_area_conditions:
		condition.finalize()
