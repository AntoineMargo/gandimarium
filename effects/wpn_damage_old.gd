extends Effect

class_name WeaponDamagingEffect

@export var resistance: String = "physical"

func apply(source, target, degree: int) -> void:
	#var user = source.user
	var weapon = source.weapon
	var dice_number = weapon.dice_number
	var damage_die = weapon.damage_die
	var damage_bonus = weapon.damage_bonus
	var damage_pattern = weapon.attack_types[source.attack_type]
	
	var total_damage = CombatMath.determine_damage(
		dice_number, damage_die,
		damage_bonus, degree,
		damage_pattern)
	if target and target.data.has_method("take_damage"):
		target.data.take_damage(total_damage, resistance)
