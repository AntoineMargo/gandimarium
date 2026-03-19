extends Resource
class_name ActivityModifier

@export var name: String = "placeholder"
@export var id: String = "placeholder"

# pre-runtime
func modify_activity(_activity: Activity):
	pass

# runtime before resolution
func apply_pre_mods(_ctx: ActivityContext):
	pass
	
# runtime after resolution
func apply_post_mods(_ctx: ActivityContext):
	pass
