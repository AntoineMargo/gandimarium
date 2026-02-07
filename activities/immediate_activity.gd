extends Activity
class_name ImmediateActivity

func execute() -> void:
	_apply_act_mods()
	_setup_concentration()

	target_entities.clear()
	target_points.clear()

	var self_ctx = _build_context(user)

	if affected_type == Activity.AffectedType.ENTITIES and reach == 0:
		target_entities = [self_ctx.origin]
	else:
		WorldMath.shape_burst(target_entities, self_ctx.origin, self_ctx.reach)

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				return

	if target_entities.is_empty():
		return
	for target in target_entities:
		var ctx = _build_context(target)
		var passes_all_filters = true
		for filter in target_filters:
			if filter is Filter:
				if not filter.is_satisfied(ctx):
					passes_all_filters = false
					break
		if not passes_all_filters:
			continue

		_apply_pre_mods(ctx)
		_roll(ctx)
		_apply_post_mods(ctx)
		if requires_roll:
			_resolve(ctx)

		for effect in target_effects:
			if effect is Effect:
				if effect.has_method("apply_context"):
					effect.apply_context(ctx)
				else:
					effect.apply(self, ctx.target, ctx.degree)

		for effect in self_per_target_effects:
			if effect is Effect:
				if effect.has_method("apply_context"):
					effect.apply_context(ctx)
				else:
					effect.apply(self, ctx.user, ctx.degree)

	for effect in self_final_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	_consume_ap(self_ctx)
	_consume_pp(self_ctx)
	_finalize_concentration()
	SignalBus.update_ui_for_char.emit()
