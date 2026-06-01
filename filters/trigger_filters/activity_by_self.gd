extends TriggerFilter
class_name ActivityBySelfFilter

func is_satisfied(ctx: Context, source: Entity = null) -> bool:
	if ctx is not ActivityContext:
		return false
	
	if ctx.activity.user != source:
		return false
		
	return true

#func is_satisfied(_context: ActivityContext) -> bool:
	#return true
