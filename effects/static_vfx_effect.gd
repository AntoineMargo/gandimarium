extends Effect
class_name StaticVFXEffect

@export var vfx_scene: PackedScene

@export var use_global_position: bool = true

func apply_context(ctx: Context) -> void:
	if not vfx_scene:
		return

	var vfx = vfx_scene.instantiate()
	vfx.modulate = Color(0.5, 0.5, 0.5, 0.5)

	ctx.target.vfx_container.add_child(vfx)

	if use_global_position:
		vfx.global_position = ctx.target.global_position

	ctx.condition.vfx_instance = vfx

func remove_context(ctx: Context):
	if is_instance_valid(ctx.condition.vfx_instance):
		ctx.condition.vfx_instance.queue_free()
		ctx.condition.vfx_instance = null

func remove(_source, target, _degree):
	pass
	#if is_instance_valid(ctx.condition.vfx_instance):
		#ctx.condition.vfx_instance.queue_free()
		#ctx.condition.vfx_instance = null

func apply(source, target, _degree: int = 2) -> void:
	if not vfx_scene:
		return

	var vfx = vfx_scene.instantiate()
	vfx.modulate = Color(0.5, 0.5, 0.5, 0.5)

	target.vfx_container.add_child(vfx)

	if use_global_position:
		vfx.global_position = target.global_position


#func apply_context(ctx: Context) -> void:
	#if not vfx_scene:
		#return
#
	#var vfx = vfx_scene.instantiate()
#
	#if attach_to_target:
		#ctx.target.vfx_container.add_child(vfx)
	#else:
		#var parent = ctx.user
		#parent.add_child(vfx)
#
		#if use_global_position:
			#vfx.global_position = ctx.target.global_position
