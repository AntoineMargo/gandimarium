extends ActivityModifier
class_name BeforeModifier

@export var tag_override: bool = false
@export var tag: String = ""
@export var property: String = ""
@export var delta: int = 0

# pre-runtime
func modify_activity(activity: Activity):
	if not tag_override:
		if not activity.has_tag(tag):
			return
		
	var current = null
	if property in activity:
		current = activity.get(property)
	if current != null:
		if property in activity:
				activity.set(property, current + delta)
		elif property in activity:
				activity.set(property, current + delta)

# runtime before resolution
func apply_pre_mods(_ctx: ActivityContext):
	pass
	
# runtime after resolution
func apply_post_mods(_ctx: ActivityContext):
	pass
