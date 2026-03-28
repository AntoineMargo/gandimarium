extends Effect
class_name StaticVFXEffect

@export var vfx_scene: PackedScene

@export var attach_to_target: bool = true
@export var use_global_position: bool = true

func apply(source, target, _degree: int = 2) -> void:
	if not vfx_scene:
		return

	var vfx = vfx_scene.instantiate()

	if attach_to_target:
		target.vfx_container.add_child(vfx)
	else:
		var parent = source.get_parent()
		parent.add_child(vfx)

		if use_global_position:
			vfx.global_position = target.global_position

#func apply_context(ctx: ActivityContext) -> void:
	#pass
