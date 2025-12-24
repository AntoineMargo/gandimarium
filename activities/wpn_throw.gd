extends WeaponActivity
class_name WeaponThrow

@export var reach_mult: int = 1

func execute() -> void:
	print("§§§ WeaponThrow called §§§")
	reach = user.data.brawn * reach_mult
	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return

	if target_entities.is_empty():
		return
	for target in target_entities:
		if not WorldMath.char_in_range(user, target, reach):
			SignalBus.dialog_out_of_range.emit()
			return
		if not WorldMath.has_line_of_sight(user, target):
			SignalBus.dialog_no_line_of_sight.emit()
			return
		var passes_all_filters = true
		for filter in target_filters:
			if filter is Filter:
				if not filter.is_satisfied(target, self):
					passes_all_filters = false
					break
		if not passes_all_filters:
			continue

		var user_stat = user.data.get(attacking_aptitude)
		var target_stat = target.data.get(defending_aptitude)
		
		var user_roll = CombatMath.standard_roll()
		var target_roll = CombatMath.standard_roll()
		
		SignalBus.dialog_show_message.emit(
			"%s rolled %d against %s's %d." % [user.data.name, user_stat+user_roll, target.data.name, target_stat+target_roll])
		
		var result = CombatMath.make_opposed_check(
			user_stat, user_roll,
			target_stat, target_roll)
		var degree = CombatMath.determine_degree_success(result)

		for effect in target_effects:
			if effect is Effect:
				effect.apply(self, target, degree)

		for effect in self_effects:
			if effect is Effect:
				effect.apply(self, user, degree)

		user.data.consume_ap(AP_cost)
		SignalBus.update_ui_for_char.emit()
