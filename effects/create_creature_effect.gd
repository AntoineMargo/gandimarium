extends Effect
## Must be linked to a condition.
class_name CreateCreatureEffect

@export var creature_data_path: String = ""
#@export var creature_data: CreatureData = null

func apply_context(ctx: Context) -> bool:
	var wm = Global.world_manager
	var map_data: MapData = Global.map_manager.get_map_data_from_coords(ctx.target)
	var creature_instance: Creature = wm.spawn_creature_at_coords(creature_data_path, ctx.target, map_data.name)
	ctx.created_creatures.append(creature_instance)
	if ctx is ActivityContext and ctx.condition:
		ctx.condition.linked_creatures.append(creature_instance)
	if ctx.shared_context and not ctx.shared_context.created_conditions.is_empty():
		for condition in ctx.shared_context.created_conditions:
			condition.linked_creatures.append(creature_instance)
	return true
