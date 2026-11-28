extends Node

@export var hit_curve: Curve
var shader_material: ShaderMaterial
var hit_tween: Tween

const HIT_FLASH_COLOR: Color = Color(1, 0.1, 0.1)  # greyish-white
const MISS_FLASH_COLOR: Color = Color(0.85, 0.85, 0.9)  # greyish-white

func play_hit_flash(damage: float, max_damage: float = 30.0, min_intensity: float = 0.2, max_intensity: float = 1.0):
	
	if hit_tween and hit_tween.is_running():
		hit_tween.kill()
		
	shader_material.set_shader_parameter("hit_color", HIT_FLASH_COLOR)

	hit_tween = create_tween()

	var t = clamp(damage / max_damage, 0.0, 1.0)
	var intensity_multiplier = min_intensity + (max_intensity - min_intensity) * t

	hit_tween.tween_method(
		func(t_local):
			var v = hit_curve.sample(t_local) * intensity_multiplier
			shader_material.set_shader_parameter("hit_intensity", v),
		0.0,
		1.0,
		0.2
	)


func play_miss_flash(intensity: float = 1, duration: float = 0.16) -> void:
	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	shader_material.set_shader_parameter("hit_color", MISS_FLASH_COLOR)

	hit_tween = create_tween()
	hit_tween.tween_method(
		func(t_local):
			var v = hit_curve.sample(t_local) * intensity
			shader_material.set_shader_parameter("hit_intensity", v),
		0.0,
		1.0,
		duration
	)


func set_healthy_tint():
	shader_material.set_shader_parameter("wounded_amount", 0.0)
	shader_material.set_shader_parameter("wounded_strength", 0.0)
	
	shader_material.set_shader_parameter("grayscale_amount", 0.0)

func set_wounded_tint():
	shader_material.set_shader_parameter("wounded_amount", 1.0)
	shader_material.set_shader_parameter("wounded_strength", 0.5)
	
	shader_material.set_shader_parameter("grayscale_amount", 0.0)

func set_dead_tint():
	shader_material.set_shader_parameter("wounded_amount", 0.0)
	shader_material.set_shader_parameter("wounded_strength", 0.0)
	
	shader_material.set_shader_parameter("grayscale_amount", 0.9)

func _ready() -> void:
	pass
