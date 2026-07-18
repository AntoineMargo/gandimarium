@abstract
extends HTNPrecondition
class_name RangePrecondition

func check(ctx: ActivityContext) -> bool:
	return true
	#if ctx.activity.is_valid_target_point(ctx.target, ctx.activity.reach_requires_LOS):
		#return true
	#else:
		#return false
