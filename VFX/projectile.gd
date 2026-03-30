extends Node2D
class_name Projectile

@export var sprite: String
@export var hit_effect_scene: PackedScene
@export var speed: float = 300.0

var target = null
var payload: Array[Callable] = []
var activity_already_hit = null
var proj_already_hit: Dictionary = {}
var prev_position: Vector2

#func _schedule_hits(from_pos: Vector2):
	#for entry in payload:
		#var target = entry.target
		#var delayed_call = entry.call
#
		#var target_pos = target.global_position
		#var dist = from_pos.distance_to(target_pos)
		#var delay = dist / speed
#
		#_schedule_single_hit(delay, target, call, already_hit)

#func _process(delta):
	#if delivery_mode != DeliveryMode.ON_TRAVEL:
		#return
#
	#_check_traversal_hits(prev_position, global_position)
	#prev_position = global_position
#
#func _check_traversal_hits(from: Vector2, to: Vector2):
	#pass
	##var tiles = WorldMath.get_tiles_along_line(from, to)
##
	##for tile in tiles:
		##var entities = WorldMath.get_entities_on_tile(tile)
##
		##for entity in entities:
			##_try_hit(entity)

#func _try_hit(target):
	#if proj_already_hit.has(target):
		#return
#
	#if activity_already_hit != null and activity_already_hit.has(target):
		#return
#
	#proj_already_hit[target] = true
#
	#if activity_already_hit != null:
		#activity_already_hit[target] = true
#
	#for effect_call in payload:
		#effect_call.call()

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

	if activity_already_hit != null:
		if activity_already_hit.has(target):
			return

		activity_already_hit[target] = true

	if payload:
		for effect_call in payload:
			effect_call.call()

	#await get_tree().create_timer(0.2).timeout
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
