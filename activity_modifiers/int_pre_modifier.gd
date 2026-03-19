extends ActivityModifier
class_name IntPreModifier

@export var tag: String = ""
@export var property: String = ""
@export var delta: int = 0

# pre-runtime
func modify_activity(activity: Activity):
	return activity

# runtime before resolution
func apply_pre_mods(ctx: ActivityContext):
	if ctx.activity.has_tag(tag):
		var current = null
		if property in ctx:
			current = ctx.get(property)
		elif property in ctx.activity:
			current = ctx.activity.get(property)
		if current != null:
			if property in ctx:
					ctx.set(property, current + delta)
			elif property in ctx.activity:
					ctx.activity.set(property, current + delta)

# runtime after resolution
func apply_post_mods(_ctx: ActivityContext):
	pass
