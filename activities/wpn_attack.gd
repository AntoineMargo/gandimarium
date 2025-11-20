extends Activity
class_name WeaponAttack

@export var user_stat_name: String = "offence"
@export var target_stat_name: String = "melee_defence"

var weapon: Weapon = null
var attack_type: int = 0

func execute(user: Node) -> void:

	attack_type = user.data.get_active_attack_type()
	if weapon is RangedWeapon or attack_type == 4:
		target_stat_name = "ranged_defence"

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return

	if target_entities.is_empty():
		return
	for filter in filters:
		if filter is Filter:
			if not filter.is_satisfied(target_entities[0], self):
				return

	var user_stat = user.data.get(user_stat_name)
	var target_stat = user.data.get(target_stat_name)
	
	var user_roll = CombatMath.standard_roll()
	var target_roll = CombatMath.standard_roll()
	var result = CombatMath.make_opposed_check(
		user_stat, user_roll,
		target_stat, target_roll)
	var degree = CombatMath.determine_degree_success(result)
	var dice_number = weapon.dice_number
	var damage_die = weapon.damage_die
	var damage_bonus = weapon.damage_bonus
	var damage_pattern = weapon.attack_types[attack_type]
	
	var total_damage = CombatMath.determine_damage(dice_number, damage_die, damage_bonus, degree, damage_pattern)
	if data.target and data.target.data.has_method("take_damage"):
		data.target.data.take_damage(total_damage, data.resistance)
