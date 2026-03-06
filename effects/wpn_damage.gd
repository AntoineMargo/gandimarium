extends Effect
class_name WeaponDamageEffect

@export var dice_number: int = 2
@export var damage_die: int = 10
@export var damage_bonus: int = 0
@export var resistance: Enums.Resistance = Enums.Resistance.NONE

func apply(source, target, degree: int = 2) -> void:
	#var hand = source.user.data.equipment.active_hand
	var category = source.user.data.equipment.active_category

	var chosen_attack_type = -1
	if category == Enums.AttackCategory.STRIKE:
		chosen_attack_type = source.weapon.selected_attacks[Enums.AttackCategory.STRIKE]
	elif category == Enums.AttackCategory.SHOOT:
		chosen_attack_type = source.weapon.selected_attacks[Enums.AttackCategory.SHOOT]
	elif category == Enums.AttackCategory.THROW:
		chosen_attack_type = source.weapon.selected_attacks[Enums.AttackCategory.THROW]
	
	var damage_pattern: DamagePattern = null
	
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
	if target and target.has_method("take_damage"):
		target.take_damage(total_damage, resistance)
	print("damage done (before armour): %d" % total_damage)
