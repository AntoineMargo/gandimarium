extends Effect
## Must be linked to a condition.
class_name CreateMapEffect

@export var map: PackedScene = null

func apply_context(ctx: Context) -> bool:
	var map_data: MapData = null
	map_data = Global.map_manager.create_map(map)
	ctx.created_maps.append(map_data)
	if ctx is ActivityContext and ctx.condition:
		ctx.condition.linked_maps.append(map_data)
	if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		for condition in ctx.shared_context.created_conditions:
			condition.linked_maps.append(map_data)
	return true
