extends Node2D
class_name Projectile

@export var sprite: String
@export var hit_effect_scene: PackedScene
@export var speed: float = 300.0
var target = null
var payload: Array[Callable] = []
var already_hit = null

func setup(config: ProjectileConfig):
	$Sprite2D.texture = config.texture
	$Sprite2D.modulate = config.color
	hit_effect_scene = config.hit_effect_scene
	speed = config.speed

func spawn_hit_effect(pos):
	if hit_effect_scene:
		var fx = hit_effect_scene.instantiate()
		fx.global_position = pos
		get_parent().add_child(fx)

func _on_hit(target_pos):
	spawn_hit_effect(target_pos)

	if has_node("GPUParticles2D"):
		$GPUParticles2D.emitting = false

	if already_hit != null:
		if already_hit.has(target):
			return

		already_hit[target] = true

	if payload:
		for effect_call in payload:
			effect_call.call()

	#await get_tree().create_timer(0.2).timeout
	queue_free()

func launch_with_payload(ctx: ActivityContext):
	target = ctx.target
	payload = ctx.delayed_calls
	if ctx.already_hit != null:
		already_hit = ctx.already_hit
	launch(ctx.user.global_position, ctx.target.global_position)

func launch(from: Vector2, to: Vector2):
	global_position = from
	look_at(to)

	var distance = from.distance_to(to)
	var duration = distance / speed

	var tween = create_tween()
	tween.tween_property(self, "global_position", to, duration)\
		.set_trans(Tween.TRANS_LINEAR)

	tween.finished.connect(_on_hit.bind(to))

func _ready() -> void:
	pass
