extends Resource
class_name ActivityModifier

@export var name: String = "placeholder"
@export var id: String = "placeholder"

# pre-runtime
func modify_activity(activity: Activity):
	pass

# runtime before resolution
func apply_pre_mods(ctx: ActivityContext):
	pass
	
# runtime after resolution
func apply_post_mods(ctx: ActivityContext):
	pass
