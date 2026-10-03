extends Effect
## Must be linked to a condition.
class_name CreateDimensionEffect

@export var dimension: PackedScene = null

func apply_context(ctx: Context) -> bool:
	var dimension_data: DimensionData = null
	dimension_data = Global.dimension_manager.create_dimension(dimension)
	ctx.created_dimensions.append(dimension_data)
	if ctx is ActivityContext and ctx.condition:
		ctx.condition.linked_dimensions.append(dimension_data)
	if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		for condition in ctx.shared_context.created_conditions:
			condition.linked_dimensions.append(dimension_data)
	return true
