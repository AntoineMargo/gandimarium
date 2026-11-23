extends Effect
## Must be linked to a condition.
class_name CreateDimensionEffect

#@export var map: PackedScene = null
@export var map: String = ""

func apply_context(ctx: Context) -> bool:
	var map_data: MapData = Global.map_manager.load_map(map)
	ctx.created_maps.append(map_data)

	if ctx is ActivityContext and ctx.shared_context:
		var shared_context: SharedContext = ctx.shared_context
		shared_context.created_maps.append(map_data)

		if !shared_context.created_conditions.is_empty():
			var condition: Condition = shared_context.created_conditions.back()
			condition.linked_maps.append(map_data)

	return true
