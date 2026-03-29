extends Effect
class_name ProjVFXEffect

@export var projectile_scene: PackedScene
@export var config: ProjectileConfig

func apply(source, target, _degree: int = 2):
	var proj = projectile_scene.instantiate()
	proj.setup(config)

	#var parent = source.get_tree().current_scene
	var parent = source.user.get_parent()
	parent.add_child(proj)

	proj.launch_with_payload(source.user.global_position, target.global_position, source.delayed_calls)
	#proj.launch(source.user.global_position, target.global_position)

func apply_context(ctx: ActivityContext) -> void:
	var proj = projectile_scene.instantiate()
	proj.setup(config)

	#var parent = source.get_tree().current_scene
	var parent = ctx.user.get_parent()
	parent.add_child(proj)
	
	proj.launch_with_payload(ctx)
	#proj.launch_with_payload(ctx.user.global_position, ctx.target.global_position, ctx.delayed_calls, ctx.already_hit)
