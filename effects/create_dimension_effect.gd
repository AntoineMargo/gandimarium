extends Effect
## Must be linked to a condition.
class_name CreateMapEffect

#@export var map: PackedScene = null
@export var map: String = ""

func apply_context(ctx: Context) -> bool:
	var map_data: MapData = Global.map_manager.load_map(map)
	if ctx is ActivityContext and ctx.condition:
		ctx.condition.linked_maps.append(map_data)
	if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		for condition in ctx.shared_context.created_conditions:
			condition.linked_maps.append(map_data)
	return true
