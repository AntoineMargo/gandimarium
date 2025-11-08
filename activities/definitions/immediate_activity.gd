extends Activity

class_name ImmediateActivity

func execute(user: Node, context: Dictionary) -> void:
	self.user = user
	if requires_concentration:
		concentration = Concentration.new()
		concentration.source = self
	target_entities.clear()
	target_points.clear()
	var cm = Global.crisis_manager
	if affected_type == Activity.AffectedType.ENTITIES and reach == 0:
		target_entities = [user]

	else:
		cm.shape_burst(target_entities, user, reach)

	for target in target_entities:
		var passes_all_filters = true
		for filter in filters:
			if filter is Filter:
				if not filter.is_satisfied(target, self):
					passes_all_filters = false
					break
		if not passes_all_filters:
			continue

		var degree = cm.roll_hostile_activity(user, attacking_aptitude, target, defending_aptitude)
		print("degree: ", degree)
		for effect in effects:
			if effect is Effect:
				effect.apply(self, target, degree)
	if requires_concentration:
		if concentration.has_connections("ended"):
			user.data.add_concentration(concentration)
		else:
			concentration.cancel()
	
