extends BeforeModifier
class_name BeforeModifierThrow


# pre-runtime
func modify_activity(activity: Activity):
	if not tag_override:
		if not activity.has_tag(tag):
			return

	activity.reach = activity.reach * activity.user.data.attributes.brawn

# runtime before resolution
func apply_pre_mods(_ctx: ActivityContext):
	pass
	
# runtime after resolution
func apply_post_mods(_ctx: ActivityContext):
	pass
