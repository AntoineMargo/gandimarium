extends Node

@export var hit_curve: Curve
var hit_material: ShaderMaterial
var hit_tween: Tween

func play_hit_flash(damage: float, max_damage: float = 10.0, min_intensity: float = 0.2, max_intensity: float = 1.0):
	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	hit_tween = create_tween()

	var t = clamp(damage / max_damage, 0.0, 1.0)
	var intensity_multiplier = min_intensity + (max_intensity - min_intensity) * t

	hit_tween.tween_method(
		func(t_local):
			var v = hit_curve.sample(t_local) * intensity_multiplier
			hit_material.set_shader_parameter("intensity", v),
		0.0,
		1.0,
		0.2
	)

#func play_hit_flash():
	#if hit_tween and hit_tween.is_running():
		#hit_tween.kill()
#
	#hit_tween = create_tween()
#
	#hit_tween.tween_method(
		#func(t):
			#var v = hit_curve.sample(t)
			#hit_material.set_shader_parameter("intensity", v),
		#0.0,
		#1.0,
		#0.2
	#)

func _ready() -> void:
	pass
