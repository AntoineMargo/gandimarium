extends Effect
class_name ProjVFXEffect

@export var projectile_scene: PackedScene
@export var config: ProjectileConfig

func apply_context(ctx: ActivityContext) -> void:
	var proj = projectile_scene.instantiate()
	proj.setup(config)

	var parent = ctx.user.get_parent()
	parent.add_child(proj)
	
	ctx.projectile_instance = proj
	
	proj.launch_with_payload(ctx)
	
