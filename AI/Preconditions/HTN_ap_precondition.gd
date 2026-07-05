@abstract
extends HTNPrecondition
class_name APPrecondition

func check(ctx: ActivityContext) -> bool:
	if ctx.user.data.current_ap >= ctx.activity.ap:
		return true
	else:
		return false
