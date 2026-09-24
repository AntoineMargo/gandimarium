extends TriggerFilter
class_name ActivityHasTagsFilter

@export var tags: Array[Enums.ActivityTag]

func is_satisfied(ctx: Context, _source: Entity = null) -> bool:
	if ctx is not ActivityContext:
		return false
	
	var activity: Activity = ctx.activity
	
	for tag in tags:
		if not activity.has_tag(tag):
			return false

	return true
