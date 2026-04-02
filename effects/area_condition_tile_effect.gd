extends Effect
class_name AreaConditionTileEffect

func apply(_source, _target, _degree: int = 2) -> void:
	pass

func apply_context(ctx: ActivityContext) -> void:
	var wm = Global.world_manager
	if ctx.condition and ctx.condition is AreaCondition:
		if not wm.layers["content"].has(ctx.target):
			wm.layers["content"][ctx.target] = []
		wm.layers["content"][ctx.target].append(ctx.condition)

		ctx.condition.affected_tiles.append(ctx.target)
