extends TargetedActivity
class_name TargetedChainActivity

@export var max_jumps: int = 2

func find_next_target(ctx):
	return ctx.user

func execute_single_target(ctx):
	if projectile:
		projectile.apply_context(ctx)
		await ctx.projectile_instance.finished
	else:
		for delayed_call in ctx.delayed_calls:
			delayed_call.call()

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
			
			process_barriers(ctx)

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
				projectile.apply_context(frozen_ctx)
				await frozen_ctx.projectile_instance.finished
			else:
				for delayed_call in frozen_ctx.delayed_calls:
					delayed_call.call()
				
			find_next_target(ctx)
			
			var current = ctx.target
			var visited = {}
			#var origin_position = current.get_coords()

			for i in max_jumps:
				if current == null:
					break

				var step_ctx = ctx.clone()
				step_ctx.target = current
				step_ctx.projectile_instance = null
				step_ctx.delayed_calls.clear()

				await execute_single_target(step_ctx)

				visited[current] = true

				#if is_instance_valid(current):
					#origin_position = current.get_coords()

				current = find_next_target(step_ctx)

	for effect in self_final_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	_consume_ap(self_ctx)
	_consume_pp(self_ctx)
	_finalize_concentration(self_ctx)
	_cleanup()
