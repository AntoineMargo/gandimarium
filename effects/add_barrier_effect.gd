extends Effect
class_name AddBarrierEffect

@export var barrier: Barrier = null

func apply_context(ctx: Context) -> bool:
	ctx.target.add_barrier(barrier, ctx)
	return true
