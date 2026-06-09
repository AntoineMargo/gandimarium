extends Effect
class_name AreaConditionTileEffect

func apply_context(ctx: Context) -> bool:
	var wm = Global.world_manager
	var pos = ctx.target
	var layer_pos = Vector2i(pos.x, pos.y)
	if ctx is ActivityContext and ctx.shared_context and ctx.shared_context.created_area_conditions:
		for area_condition in ctx.shared_context.created_area_conditions:
			if not wm.layers[pos.z]["contents"].has(layer_pos):
				wm.layers[pos.z]["contents"][layer_pos] = []
			wm.layers[pos.z]["contents"][layer_pos].append(area_condition)

			area_condition.affected_tiles.append(pos)
			var entity_on_tile = wm.get_entity_at_pos(pos)
			wm.handle_tile_conditions(pos, entity_on_tile)
	return true
