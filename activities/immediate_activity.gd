extends Activity
class_name ImmediateActivity

func preview_area(tile):
	var wm = Global.world_manager
	var tiles = compute_affected_area(tile)
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)

func execute() -> void:
	_apply_act_mods()
	_setup_concentration()

	#target_points.clear()

	var shared_ctx = _build_shared_context()
	var self_ctx = _build_context(shared_ctx, user.get_coords())

	if spread == 0:
		target_points.append(self_ctx.origin)
	else:
		target_points = compute_affected_area(self_ctx.origin)

	var final_targets = []
	
	match affected_type:
		Enums.Affected.ENTITIES:
			final_targets.append_array(WorldMath.get_entities_from_tiles(target_points))
		Enums.Affected.TERRAIN:
			final_targets.append_array(target_points)

	self_ctx.target = user

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				return
	
	for effect in self_prior_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	if final_targets.is_empty():
		return
	for target in final_targets:
		var ctx = _build_context(shared_ctx, target)
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
	target_points.clear()
	SignalBus.update_ui_for_char.emit()
