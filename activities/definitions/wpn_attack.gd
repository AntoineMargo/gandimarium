extends Activity

class_name WeaponAttack

var attack_type : int = 0

func execute(user: Node) -> void:
	var cm = Global.crisis_manager

	var user_stat = data.user_stat
	var target_stat = data.target_stat
	var result = cm.roll_hostile_activity(user, user_stat, data.target, target_stat)
	var total_damage = cm.determine_damage_wpn(data.dice_number, data.damage_die, data.damage_bonus, result, data.attack_type)

	if data.target and data.target.data.has_method("take_damage"):
		data.target.data.take_damage(total_damage, data.resistance)

func can_execute(user: Node) -> bool:
	var cm = Global.crisis_manager
	if not cm.enough_action_points(self.AP_cost):
		return false
	if not cm.meets_brawn_requirements(user, data.weapon, data.offhand):
		SignalBus.dialog_not_strong_enough.emit()
		return false
	if not cm.is_in_range(user, data.target, data.attack_range):
		SignalBus.dialog_out_of_range.emit()
		return false
	if not cm.has_line_of_sight(user, data.target):
		SignalBus.dialog_no_line_of_sight.emit()
		return false
	return true
