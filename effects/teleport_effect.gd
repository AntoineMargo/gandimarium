extends Effect
class_name TeleportEffect

func apply_context(ctx: ActivityContext) -> void:
	var wm = Global.world_manager
	wm.teleport(ctx.origin, ctx.target)
