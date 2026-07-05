extends Effect
class_name MoveEffect

@export var prop: PackedScene = null

func apply_context(ctx: Context) -> bool:
	if ctx.target is Vector3i:
		Global.world_manager.interact_move(ctx.user, ctx.target)
	return true
