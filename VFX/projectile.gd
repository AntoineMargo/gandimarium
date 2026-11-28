extends Node2D
class_name Projectile

signal hit
signal finished

# Config

var sprite: Texture2D
var sprite_scale: float = 1.0
var colour: Color = Color(1.0, 1.0, 1.0, 1.0)
var speed: float = 800.0

var trajectory_arc: float = 0.0
var trajectory_randomness: float = 0.0
var trajectory_direction_randomness: float = 0.0
var wobble_amplitude: float = 0.0
var wobble_frequency: float = 3.0

#var trail_length: int = 12
#var trail_width: int = 1
#var trail_width_curve: Curve
#var trail_colour: Color = Color(1.0, 1.0, 1.0, 1.0)

# Runtime

var hit_effect_scene: PackedScene = null
var target = null
var payload: Array[Callable] = []
var activity_already_hit = null
var proj_already_hit: Dictionary = {}
var prev_position: Vector2

var launch_position: Vector2
var destination_position: Vector2
var trajectory_offset: Vector2
var trajectory_progress: float = 0.0
var wobble_phase: float = 0.0
var trail_points: Array[Vector2] = []


func setup_particles(proj_config: ProjConfig) -> void:
	for config in proj_config.particles:
		var emitter: GPUParticles2D = GPUParticles2D.new()
		@warning_ignore("shadowed_variable_base_class")
		var material: ParticleProcessMaterial = ParticleProcessMaterial.new()

		emitter.texture = config.texture
		emitter.amount = config.amount
		emitter.lifetime = config.lifetime
		emitter.one_shot = config.one_shot
		emitter.modulate = config.colour
		emitter.explosiveness = config.explosiveness

		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
		material.direction = Vector3(
			config.direction.x,
			config.direction.y,
			0.0
		)
		material.spread = config.spread

		material.initial_velocity_min = config.velocity_min
		material.initial_velocity_max = config.velocity_max

		material.gravity = Vector3(
			config.gravity.x,
			config.gravity.y,
			0.0
		)

		material.scale_min = config.scale_min
		material.scale_max = config.scale_max

		if config.fade:
			var gradient: Gradient = Gradient.new()
			gradient.set_color(0, Color.WHITE)
			gradient.set_color(1, Color(1, 1, 1, 0))

			var ramp: GradientTexture1D = GradientTexture1D.new()
			ramp.gradient = gradient

			material.color_ramp = ramp

		emitter.process_material = material
		emitter.name = "ParticleEmitter_%d" % get_child_count()

		add_child(emitter)
		emitter.emitting = true


func configure(config: ProjConfig) -> void:
	sprite = config.sprite
	sprite_scale = config.sprite_scale
	colour = config.colour
	speed = config.speed
	trajectory_arc = config.trajectory_arc
	trajectory_randomness = config.trajectory_randomness
	trajectory_direction_randomness = config.trajectory_direction_randomness
	wobble_amplitude = config.wobble_amplitude
	wobble_frequency = config.wobble_frequency

	$Sprite2D.texture = sprite
	$Sprite2D.modulate = colour
	$Sprite2D.scale = Vector2.ONE * sprite_scale

	setup_particles(config)


@warning_ignore("shadowed_variable_base_class")
func make_particles(
	pos: Vector2,
	direction: Vector2 = Vector2.UP,
	amount: int = 20,
	lifetime: float = 0.5,
	velocity: float = 100.0,
	spread: float = 180.0,
	scale: float = 0.15,
	burst_colour: Color = Color.WHITE
) -> void:

	var particles = GPUParticles2D.new()
	@warning_ignore("shadowed_variable_base_class")
	var material = ParticleProcessMaterial.new()

	particles.texture = sprite
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.emitting = false
	particles.modulate = burst_colour

	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	material.direction = Vector3(direction.x, direction.y, 0.0)
	material.spread = spread
	material.initial_velocity_min = velocity * 0.5
	material.initial_velocity_max = velocity
	material.gravity = Vector3.ZERO
	material.scale_min = scale * 0.5
	material.scale_max = scale

	particles.process_material = material

	particles.global_position = pos
	particles.finished.connect(particles.queue_free)

	get_parent().add_child(particles)
	particles.emitting = true


func detach_particles() -> void:
	var particle_parent = get_parent()

	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = false
			child.reparent(particle_parent, true)

			get_tree().create_timer(child.lifetime).timeout.connect(child.queue_free)


func spawn_hit_effect(pos, ctx: ActivityContext):
	if hit_effect_scene:
		var fx = hit_effect_scene.instantiate()
		fx.context = ctx
		fx.global_position = pos
		get_parent().add_child(fx)


func _on_hit(target_pos, ctx: ActivityContext):
	var wm = Global.world_manager
	var pixel_pos: Vector2 = wm.tile_to_pixels(target_pos)
	spawn_hit_effect(pixel_pos, ctx)

	detach_particles()
	#if has_node("GPUParticles2D"):
		#$GPUParticles2D.emitting = false

	if activity_already_hit != null and activity_already_hit.has(target):
		finished.emit()
		queue_free()
		return

	if activity_already_hit:
		activity_already_hit[target] = true

	if payload:
		for effect_call in payload:
			effect_call.call()

	hit.emit(target)
	finished.emit()
	queue_free()


func launch_with_payload(ctx: ActivityContext):
	target = ctx.target
	payload = ctx.delayed_calls
	if ctx.already_hit != null:
		activity_already_hit = ctx.already_hit
	if target is Object and target.has_method("get_coords"):
		launch(ctx.user.get_coords(), ctx.target.get_coords(), ctx)
	elif target is Barrier:
		launch(ctx.user.get_coords(), ctx.target.parent_creature.get_coords(), ctx)
	else:
		launch(ctx.user.get_coords(), ctx.target, ctx)


func launch(from_tile: Vector3i, to_tile: Vector3i, ctx: ActivityContext):
	var wm = Global.world_manager
	var from_pos: Vector2 = wm.tile_to_pixels(from_tile)
	var to_pos: Vector2 = wm.tile_to_pixels(to_tile)

	launch_position = from_pos
	destination_position = to_pos
	global_position = from_pos

	var direction = (to_pos - from_pos).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)

	var arc_magnitude = trajectory_arc

	# Randomize arc magnitude.
	if trajectory_randomness > 0.0:
		arc_magnitude *= randf_range(
			1.0 - trajectory_randomness,
			1.0 + trajectory_randomness
		)

	# Occasionally reverse arc direction.
	if randf() < trajectory_direction_randomness:
		arc_magnitude *= -1.0

	trajectory_offset = perpendicular * arc_magnitude

	wobble_phase = randf() * TAU

	look_at(to_pos)

	var distance = from_pos.distance_to(to_pos)
	var duration = distance / speed

	var tween = create_tween()
	tween.tween_method(
		_update_trajectory,
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_LINEAR)

	tween.finished.connect(_on_hit.bind(to_tile, ctx))


func _update_trajectory(progress: float):
	trajectory_progress = progress

	var control_point = (
		launch_position
		+ (destination_position - launch_position) * 0.5
		+ trajectory_offset
	)

	# Quadratic Bézier interpolation
	var p = (
		(1.0 - progress) * (1.0 - progress) * launch_position
		+ 2.0 * (1.0 - progress) * progress * control_point
		+ progress * progress * destination_position
	)

	# Optional wobble
	if wobble_amplitude > 0.0:
		var direction = (destination_position - launch_position).normalized()
		var perpendicular = Vector2(-direction.y, direction.x)

		var wobble = sin(
			progress * wobble_frequency * TAU + wobble_phase
		) * sin(progress * PI) * wobble_amplitude

		p += perpendicular * wobble

	global_position = p


func _process(_delta: float):
	return


func _ready() -> void:
	pass
