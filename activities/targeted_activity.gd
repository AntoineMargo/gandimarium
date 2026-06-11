extends Activity
class_name TargetedActivity

@export var number_of_targets: int = 1
var number_of_targets_left = 0
var cm = null
var wm = null

func _visual_pounce(targets: Array, ctx: Context):
	if targets.size() == 1:
		for tag in tags:
			if Enums.Tag.MELEE:
				var origin_tile: Vector2 = Vector2(ctx.origin.x, ctx.origin.y)
				var target_tile: Vector2 = Vector2(targets[0].x, targets[0].y)
				var target_dir: Vector2 = (target_tile - origin_tile).normalized()
				user.pounce_attack(target_dir)

func pre_execution_bundle_modify(ctx: Context):
	super.pre_execution_bundle_modify(ctx)
	number_of_targets = modify_value(number_of_targets, Enums.ValueType.NUMBER_OF_TARGETS, ctx, Enums.ActivityStage.PRE_EXECUTION)

func handle_hover(tile: Vector3i) -> void:
	var tiles = compute_affected_area(tile)
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	if shape == Enums.Shape.BURST:
		if not is_valid_target_point(tile, reach_requires_LOS):
			wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines, Color(255, 0, 0, 255))
			return
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				select_target()
			MOUSE_BUTTON_RIGHT:
				cancel_activity()

func _cleanup() -> void:
	SignalBus.change_cursor.emit("default")
	Global.activity_handler = null
	wm.clear_all_visualizations()
	for hl in wm.target_highlights:
		hl.queue_free()
	wm.target_highlights.clear()
	cm = null
	wm = null
	origin = Vector3i(0, 0, 0)
	target_points.clear()
	SignalBus.update_ui_for_char.emit()

func execute() -> void:
	cm = Global.crisis_manager
	wm = Global.world_manager
	_import_context()
	origin = user.get_coords()
	var pre_ctx = _build_context()
	pre_execution_bundle_modify(pre_ctx)
	if target_points:
		resolve_with_targets(target_points)
	else:
		Global.last_hovered_tile = Vector3i(-1,-1,-1)
		resolve_ui()

func resolve_ui() -> void:
	SignalBus.dialog_show_message.emit("Waiting for target(s) of activity...")
	Global.activity_handler = self
	self.user = user
	number_of_targets_left = number_of_targets
	SignalBus.dialog_selectable_targets.emit(number_of_targets_left)
	target_points.clear()
	SignalBus.change_cursor.emit("select2")

func cancel_activity():
	SignalBus.dialog_show_message.emit("Canceling activity.")
	_cleanup()

func select_target():
	print("number_of_targets_left: ", number_of_targets_left)
	var coords = wm.get_hovered_tile()
	if is_valid_target_point(coords, reach_requires_LOS):
		if targeting_type == Enums.Targeting.ENTITIES:
			var entity = wm.get_entity_at_pos(coords)
			if not entity or not validate_condition_absence(entity):
				SignalBus.dialog_show_message.emit("No valid entity there.")
				return
		target_points.append(coords)
		number_of_targets_left -= 1

		if number_of_targets_left > 0:
			var tiles = compute_affected_area(coords)
			wm.visualize_area(tiles, wm.committed_visualized_rects, wm.committed_visualized_lines)
			SignalBus.dialog_selectable_targets.emit(number_of_targets_left)

		if number_of_targets_left == 0:
			resolve_with_targets(target_points)
	else:
		SignalBus.dialog_show_message.emit("Invalid target.")

func compute_hit_delay(final_target, batch_ctx: ActivityContext) -> float:
	var target_pos: Vector3i
	if final_target is Entity:
		target_pos = final_target.get_coords()
	else:
		target_pos = final_target

	var dist = WorldMath.dist_weighted_3d(batch_ctx.origin, target_pos)
	var speed_tiles = projectile.config.speed / Global.TILE_SIZE

	return dist / speed_tiles

func _schedule_call(delayed_call: Callable, call_delay: float, already_hit, target):
	_run_scheduled(delayed_call, call_delay, already_hit, target)

func _run_scheduled(delayed_call: Callable, call_delay: float, already_hit, target) -> void:
	await user.get_tree().create_timer(call_delay).timeout

	if already_hit != null and already_hit.has(target):
		return

	if already_hit != null:
		already_hit[target] = true

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

	SignalBus.event.emit(ReactionEvent.activity_started(self_ctx))

	_consume_ap(self_ctx)
	_consume_pp(self_ctx)

	for effect in self_prior_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	_visual_pounce(targets, self_ctx)

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

	for effect in self_final_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	_finalize_concentration(self_ctx)
	_cleanup()
	
	SignalBus.event.emit(ReactionEvent.activity_completed(self_ctx))
	
	#SignalBus.dialog_show_message.emit("Activity effects released.")
