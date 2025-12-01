extends Effect

class_name WeaponDamageEffect

@export var dice_number: int = 2
@export var damage_die: int = 10
@export var damage_bonus: int = 0
@export var resistance: String = "physical"
@export var damage_pattern: DamagePattern = null

func apply(source, target, degree: int) -> void:
	var category = source.user.data.equipment.get_active_attack_category()
	var chosen_attack_type = -1
	if category == 0:
		chosen_attack_type = source.user.data.equipment.get_active_strike_type()
	elif category == 1:
		chosen_attack_type = source.user.data.equipment.get_active_shoot_type()
	elif category == 2:
		chosen_attack_type = source.user.data.equipment.get_active_throw_type()
	
	if damage_pattern == null:
		for pattern in source.attack_types:
			if pattern.id == chosen_attack_type:
				damage_pattern = pattern
				break
	if damage_pattern == null:
		damage_pattern = Library.get_dmg_pattern("default")
	var total_damage = CombatMath.determine_damage(
		dice_number, damage_die,
		damage_bonus, degree,
		damage_pattern)
	if target and target.data.has_method("take_damage"):
		target.data.take_damage(total_damage, resistance)
