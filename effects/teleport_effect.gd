extends Effect
class_name TeleportEffect

func apply_context(ctx: Context) -> bool:
	var wm = Global.world_manager
	wm.teleport(ctx.user, ctx.target)
	return true
