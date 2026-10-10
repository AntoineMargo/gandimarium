extends Entity
class_name CreatureNode

var creature: Creature = null

var data: CreatureData:
	get:
		return creature.data if creature else _data
	set(val):
		if creature:
			creature.data = val
		_data = val

var _data: CreatureData = null

@export var health_bar_scene: PackedScene

@onready var sprite_node: Sprite2D = $Mover/Sprite2D
@onready var vfx_container: Node2D = $Mover/VFXContainer
@onready var ai_controller = $AIController
@onready var mover = $Mover

var health_bar_instance: Node


func play_hit_flash(damage: float) -> void:
	if has_node("Mover/ShaderOrchestration"):
		$Mover/ShaderOrchestration.play_hit_flash(damage)


func set_healthy_tint() -> void:
	if has_node("Mover/ShaderOrchestration"):
		$Mover/ShaderOrchestration.set_healthy_tint()


func set_wounded_tint() -> void:
	if has_node("Mover/ShaderOrchestration"):
		$Mover/ShaderOrchestration.set_wounded_tint()


func set_dead_tint() -> void:
	if has_node("Mover/ShaderOrchestration"):
		$Mover/ShaderOrchestration.set_dead_tint()


func update_hp_bar() -> void:
	if health_bar_instance and health_bar_instance.has_method("update_hp_bar"):
		health_bar_instance.update_hp_bar()


func debug_outline() -> void:
	if has_node("Mover/Outline"):
		$Mover/Outline.toggle_outline()


func rebuild_shader() -> void:
	if sprite_node == null:
		return
	var shader_mat = sprite_node.material as ShaderMaterial
	if shader_mat == null:
		return

	# Base values reset
	shader_mat.set_shader_parameter("grayscale_amount", 0.0)
	shader_mat.set_shader_parameter("wounded_amount", 0.0)
	shader_mat.set_shader_parameter("hit_intensity", 0.0)

	shader_mat.set_shader_parameter("aura_amount", 0.0)
	shader_mat.set_shader_parameter("aura_color", Color(0.7, 0.85, 1.0))

	shader_mat.set_shader_parameter("pulse_speed", 0.0)
	shader_mat.set_shader_parameter("pulse_offset", 0.0)
	shader_mat.set_shader_parameter("pulse_sharpness", 0.0)

	var accum: Dictionary = {}

	var conditions = data.conditions if data else []
	for condition in conditions:
		for effect in condition.shader_effects:
			var key = effect.parameter_name
			var value = effect.value

			if not accum.has(key):
				accum[key] = value
			else:
				accum[key] = max(accum[key], value)
				
			if effect.pulse != null:
				shader_mat.set_shader_parameter("pulse_speed", effect.pulse.speed)
				shader_mat.set_shader_parameter("pulse_offset", effect.pulse.offset)
				shader_mat.set_shader_parameter("pulse_sharpness", effect.pulse.sharpness)

	for key in accum:
		shader_mat.set_shader_parameter(key, accum[key])


func pounce_attack(target_dir: Vector2) -> void:
	var pounce_distance: float = 6.0
	var forward = target_dir.normalized() * pounce_distance
	
	var tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)

	# forward lunge
	tween.tween_property(sprite_node, "position", forward, 0.05)

	# snap back
	tween.tween_property(sprite_node, "position", Vector2.ZERO, 0.08)


func update_visibility(map_id: String, current_layer: int) -> void:
	if not data:
		return
	if map_id == data.map_id and current_layer == data.tile_z:
		self.visible = true
	else:
		self.visible = false


# Convenience delegate methods in case external code calls them on CreatureNode:
func get_stat(stat):
	if creature:
		return creature.get_stat(stat)
	return 0


func get_coords() -> Vector3i:
	if creature:
		return creature.get_coords()
	if data:
		return Vector3i(data.tile_x, data.tile_y, data.tile_z)
	return Vector3i.ZERO


func set_coords(new_coords: Vector3i) -> void:
	if creature:
		creature.set_coords(new_coords)
	elif data:
		data.tile_x = new_coords.x
		data.tile_y = new_coords.y
		data.tile_z = new_coords.z


func _ready() -> void:
	print("CreatureNode getting ready!")
	if not health_bar_scene:
		print("Health bar scene not set!")
	else:
		health_bar_instance = health_bar_scene.instantiate()
		$Mover.add_child(health_bar_instance)
	mover.position = Vector2.ZERO
	if sprite_node and has_node("Mover/ShaderOrchestration"):
		$Mover/ShaderOrchestration.shader_material = sprite_node.material as ShaderMaterial
	SignalBus.update_visibility.connect(update_visibility)
	if data and data.sprite and sprite_node and ResourceLoader.exists(data.sprite):
		sprite_node.texture = load(data.sprite)
	rebuild_shader()


func _exit_tree() -> void:
	if creature and creature.node == self:
		creature.detach_node(self)
