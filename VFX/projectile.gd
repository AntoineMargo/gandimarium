extends Node2D
class_name Projectile

signal hit
signal finished

@export var sprite: String
@export var hit_effect_scene: PackedScene
@export var speed: float = 300.0

var target = null
var payload: Array[Callable] = []
var activity_already_hit = null
var proj_already_hit: Dictionary = {}
var prev_position: Vector2

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
	if target is Entity:
		launch(ctx.user.get_coords(), ctx.target.get_coords())
	else:
		launch(ctx.user.get_coords(), ctx.target)

func launch(from_tile: Vector3i, to_tile: Vector3i):
	var wm = Global.world_manager
	var from_pos: Vector2 = wm.tile_to_pixels(from_tile)
	var to_pos: Vector2 = wm.tile_to_pixels(to_tile)

	global_position = from_pos
	look_at(to_pos)

	var distance = from_pos.distance_to(to_pos)
	var duration = distance / speed

	var tween = create_tween()
	tween.tween_property(self, "global_position", to_pos, duration)\
		.set_trans(Tween.TRANS_LINEAR)

	tween.finished.connect(_on_hit.bind(to_tile))

func _ready() -> void:
	pass
