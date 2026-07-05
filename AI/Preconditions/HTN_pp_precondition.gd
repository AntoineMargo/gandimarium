@abstract
extends HTNPrecondition
class_name PPPrecondition

func check(ctx: ActivityContext) -> bool:
	if ctx.user.data.current_pp >= ctx.activity.pp:
		return true
	else:
		return false
