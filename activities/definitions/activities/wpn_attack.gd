@icon("res://art/interface/activities/placeholder2.png")

extends Activity

class_name WeaponAttack

var attack_type : int = 0

func execute(user: Node, context: Dictionary) -> void:
	var cm = Global.crisis_manager
	var target = context.get("target")
	var resistance = context.get("resistance")
	var weapon : Weapon = null
	var other : Weapon = null
	if user.data.active_set == 1:
		if user.data.active_hand == 1:
			weapon = user.data.set1_left_hand
			other = user.data.set1_right_hand
		elif user.data.active_hand == 2:
			weapon = user.data.set1_right_hand
			other = user.data.set1_left_hand
	elif user.data.active_set == 2:
		if user.data.active_hand == 1:
			weapon = user.data.set2_left_hand
			other = user.data.set2_right_hand
		elif user.data.active_hand == 2:
			weapon = user.data.set2_right_hand
			other = user.data.set2_left_hand
	if weapon == null:
		var fist = Library.get_item("wpn_fist")
		weapon = fist
	
	if weapon is RangedWeapon:
		range = weapon.ranged_increment
	else:
		range = weapon.melee_range
	var dice_number = weapon.dice_number
	var damage_die = weapon.damage_die
	var damage_bonus = weapon.damage_bonus
	damage_bonus += user.data.strength_bonus
	if user.data.active_hand == 1:
		attack_type = user.data.active_attack1
	else:
		attack_type = user.data.active_attack2

	if attack_type == 0:
		attack_type = weapon.attack_type[0]

	if cm.meets_brawn_requirements(user, weapon, other):
		if cm.is_in_range(user, target, range):
			if not cm.has_line_of_sight(user, target):
				SignalBus.dialog_no_line_of_sight.emit()
				return
			if not cm.enough_action_points(self.AP_cost):
				return
			var user_stat = context.get("user_stat")
			var target_stat = context.get("target_stat")
			var result = cm.roll_hostile_activity(user, user_stat, target, target_stat)
			var total_damage = cm.determine_damage_wpn(dice_number, damage_die, damage_bonus, result, attack_type)
			if target and target.data.has_method("take_damage"):
				target.data.take_damage(total_damage, resistance)
		else:
			SignalBus.dialog_out_of_range.emit()
			return
	else:
		SignalBus.dialog_not_strong_enough.emit()
