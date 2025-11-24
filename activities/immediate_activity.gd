extends Activity

class_name ImmediateActivity

func execute() -> void:
	print("immediate act user: ", user)
	if requires_concentration:
		concentration = Concentration.new()
		concentration.source = self
	target_entities.clear()
	target_points.clear()

	if affected_type == Activity.AffectedType.ENTITIES and reach == 0:
		target_entities = [user]
	else:
		WorldMath.shape_burst(target_entities, user, reach)

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return

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

		for effect in self_effects:
			if effect is Effect:
				effect.apply(self, user, degree)

		user.data.consume_ap(AP_cost)

	if requires_concentration:
		if concentration.has_connections("ended"):
			user.data.add_concentration(concentration)
		else:
			concentration.cancel()

	SignalBus.update_ui_for_char.emit()
