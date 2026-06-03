extends Effect
class_name ExecuteActivityEffect

@export var activity: Activity = null

func apply_context(ctx: Context) -> void:
	var new_context = ctx.duplicate(true)
	var instance = activity.duplicate(true)
	instance.imported_context = new_context
	instance.target_points.append(ctx.target)
	instance.execute()
