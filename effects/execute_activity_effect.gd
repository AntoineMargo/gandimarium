extends Effect
class_name ExecuteActivityEffect

@export var reuse_resolution: bool = false
@export var activity: Activity = null

func clone_context(ctx: ActivityContext) -> ActivityContext:
	var new_ctx = ActivityContext.new()
	new_ctx.activity = ctx.activity
	new_ctx.user = ctx.user
	new_ctx.origin = ctx.origin
	new_ctx.target = ctx.target
	new_ctx.result = ctx.result
	new_ctx.degree = ctx.degree
	new_ctx.shared_context = ctx.shared_context
	new_ctx.concentration = ctx.concentration
	if reuse_resolution:
		new_ctx.reuse_resolution = true
	return new_ctx

func apply_context(ctx: Context) -> void:
	var new_context: ActivityContext = clone_context(ctx)
	var instance = activity.duplicate(true)
	instance.imported_context = new_context
	var target_point: Vector3i
	if ctx.target is Vector3i:
		target_point = ctx.target
	else:
		target_point = ctx.target.get_coords()
	instance.target_points.append(target_point)
	instance.execute()
