extends Activity
class_name WeaponAttack

var weapon: Weapon = null
var attack_type: int = 0

func execute() -> void:
	if attacking_aptitude == "default":
		attacking_aptitude = "offence"
	if defending_aptitude == "default":
		defending_aptitude = "melee_defence"
	attack_type = user.data.get_active_attack_type()
	if defending_aptitude == "default":
		if weapon is RangedWeapon or attack_type == 4:
			defending_aptitude = "ranged_defence"

	print("weapon: ", weapon)
	range = weapon.melee_range

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return

	print("activity self: ", self)
	print("activity user: ", user)
	print("activity self user: ", self.user)
	if user:
		print("activity user name: ", user.data.name)
	else:
		print("activity user name: None!")

	if target_entities.is_empty():
		return
	for target in target_entities:
		var passes_all_filters = true
		for filter in target_filters:
			if filter is Filter:
				if not filter.is_satisfied(target, self):
					passes_all_filters = false
					break
		if not passes_all_filters:
			continue

		var user_stat = user.data.get(attacking_aptitude)
		var target_stat = user.data.get(defending_aptitude)
		
		var user_roll = CombatMath.standard_roll()
		var target_roll = CombatMath.standard_roll()
		var result = CombatMath.make_opposed_check(
			user_stat, user_roll,
			target_stat, target_roll)
		var degree = CombatMath.determine_degree_success(result)
		
		for effect in target_effects:
			if effect is Effect:
				effect.apply(self, target, degree)
