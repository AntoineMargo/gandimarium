extends TargetedActivity
class_name TargetedThrowActivity

var final_reach: int = 0

func handle_hover(tile: Vector3i) -> void:
	var tiles = compute_affected_area(tile)
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	if shape == Enums.Shape.BURST:
		if not is_valid_target_point(tile, reach_requires_LOS):
			wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines, Color(255, 0, 0, 255))
			return
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)

func execute() -> void:
	cm = Global.crisis_manager
	wm = Global.world_manager
	origin = user.get_coords()
	final_reach = reach * user.data.attributes.brawn
	var pre_ctx = _build_context()
	pre_execution_bundle_modify(pre_ctx)
	if target_points:
		resolve_with_targets(target_points)
	else:
		Global.last_hovered_tile = Vector3i(-1,-1,-1)
		resolve_ui()

func drop_item_on_target(target):
	var item_in_inventory: bool = false
	for item in user.data.inventory.list:
		if item.id == weapon.id:
			user.data.inventory.remove_item(item)
			item_in_inventory = true
			break
	if not item_in_inventory:
		user.data.equipment.remove_item(weapon)
	#var coords = target.get_coords()
	wm.add_to_tile(weapon, target)
	wm.add_item_visual(target)

func resolve_with_targets(targets: Array[Vector3i]) -> void:
	remove_invalid_points(targets)
	if targets.is_empty():
		_cleanup()
		return

	_setup_concentration()
	var shared_ctx = _build_shared_context()
	var self_ctx = _build_context(shared_ctx, user.get_coords())

	var already_hit = {}

	if not _has_enough_ap_and_pp(self_ctx):
		return

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				_cleanup()
				return

	for effect in self_prior_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	for target in targets:
		var batch_payload: Array[Callable] = []
		var batch_ctx = _build_context(shared_ctx, target, already_hit)
		batch_ctx.delayed_calls = batch_payload
		
		var affected_tiles = compute_affected_area(target)
		var final_targets = []
		
		match affected_type:
			Enums.Affected.ENTITIES:
				final_targets.append_array(WorldMath.get_entities_from_tiles(affected_tiles))
			Enums.Affected.TERRAIN:
				final_targets.append_array(affected_tiles)

		for final_target in final_targets:
			var ctx = null
			if can_only_hit_once:
				ctx = _build_context(shared_ctx, final_target, already_hit)
			else:
				ctx = _build_context(shared_ctx, final_target)
			var passes_all_filters = true
			for filter in target_filters:
				if filter is Filter:
					if not filter.is_satisfied(ctx):
						passes_all_filters = false
						break
			if not passes_all_filters:
				continue

			pre_roll_bundle_modify(ctx)
			_roll(ctx)
			post_roll_bundle_modify(ctx)
			if requires_roll:
				_resolve(ctx)
			post_resolution_bundle_modify(ctx)
				
			var frozen_ctx = ctx

			for effect in target_effects:
				if effect is Effect:
					if effect.has_method("apply_context"):
						frozen_ctx.delayed_calls.append(func(): effect.apply_context(frozen_ctx))
					else:
						frozen_ctx.delayed_calls.append(func(): effect.apply(self, frozen_ctx.target, frozen_ctx.degree))

			for effect in self_per_target_effects:
				if effect is Effect:
					if effect.has_method("apply_context"):
						frozen_ctx.delayed_calls.append(func(): effect.apply_context(frozen_ctx))
					else:
						frozen_ctx.delayed_calls.append(func(): effect.apply(self, frozen_ctx.user, frozen_ctx.degree))

			if projectile:
				if shape == Enums.Shape.BURST:
					if projectile_batch_mode:
						for delayed_call in frozen_ctx.delayed_calls:
							# adding the call (effects to target) to the batch
							batch_payload.append(delayed_call)
					else:
						# firing the projectile at that target
						projectile.apply_context(frozen_ctx)
				elif shape == Enums.Shape.LINE:
					var call_delay = compute_hit_delay(frozen_ctx.target, batch_ctx)

					for delayed_call in frozen_ctx.delayed_calls:
						_schedule_call(delayed_call, call_delay, already_hit, frozen_ctx.target)
			else:
				for delayed_call in frozen_ctx.delayed_calls:
					delayed_call.call()

		if projectile:
			if shape == Enums.Shape.BURST and not batch_payload.is_empty():
				# firing a single projectile for all the calls (effects to targets) loaded into batch_ctx
				projectile.apply_context(batch_ctx)
			elif shape == Enums.Shape.LINE:
				# firing the "empty" projectile (calls are delayed separately and already)
				projectile.apply_context(batch_ctx)

		drop_item_on_target(target)

	for effect in self_final_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	_consume_ap(self_ctx)
	_consume_pp(self_ctx)
	_finalize_concentration()
	_cleanup()
	#SignalBus.dialog_show_message.emit("Activity effects released.")
