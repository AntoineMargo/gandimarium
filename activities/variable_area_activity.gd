extends TargetedActivity
class_name VariableAreaActivity

var start_tile: Vector3i
var is_dragging: bool = false

#func handle_hover(_tile: Vector3i) -> void:
	#pass

#func handle_hover(tile: Vector3i) -> void:
	#var tiles: Array[Vector3i] = [tile]
	#wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	#if not WorldMath.is_in_range(origin, tile, reach) or not WorldMath.has_line_of_sight_tile(origin, tile):
		#wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines, Color(255, 0, 0, 255))
		#return
	#wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)

func handle_hover(tile: Vector3i) -> void:
	var tiles: Array[Vector3i] = [tile]
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	if not is_valid_target_point(tile, reach_requires_LOS):
				wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines, Color(255, 0, 0, 255))
				return
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)




func compute_affected_area(target_location: Vector3i) -> Array[Vector3i]:
	var tiles: Array[Vector3i] = []
	
	match shape:
		Enums.Shape.LINE:
			tiles = WorldMath.get_line_tiles(start_tile, target_location, spread)
		Enums.Shape.BURST:
			var distance = WorldMath.dist_weighted_3d(start_tile, target_location, 1)
			if distance > spread:
				distance = spread
			tiles = WorldMath.get_burst_tiles(start_tile, distance)
			
	return tiles

func start_drag():
	var hovered_tile = wm.get_hovered_tile()
	if not is_valid_target_point(hovered_tile, reach_requires_LOS):
		return
	start_tile = hovered_tile
	is_dragging = true

func update_drag():
	if not is_dragging:
		return
	
	var end_tile = wm.get_hovered_tile()
	if end_tile == Global.last_hovered_tile:
		return
	
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	var tiles = compute_affected_area(end_tile)
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)
	Global.last_hovered_tile = end_tile

func end_drag():
	if not is_dragging:
		return []
	
	is_dragging = false
	
	var end_tile = wm.get_hovered_tile()
	return compute_affected_area(end_tile)

func handle_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed and not is_dragging:
				start_drag()

			elif not event.pressed and is_dragging:
				var new_target_points = end_drag()

				if new_target_points.size() > 0:
					target_points.append_array(new_target_points)
					wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
					wm.visualize_area(new_target_points, wm.committed_visualized_rects, wm.committed_visualized_lines)

					number_of_targets_left -= 1

					if number_of_targets_left > 0:
						SignalBus.dialog_selectable_targets.emit(number_of_targets_left)

					if number_of_targets_left == 0:
						resolve_with_targets(target_points)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
				cancel_activity()

	if event is InputEventMouseMotion and is_dragging:
		update_drag()

func _cleanup() -> void:
	SignalBus.change_cursor.emit("default")
	Global.activity_handler = null
	wm.clear_all_visualizations()
	for hl in wm.target_highlights:
		hl.queue_free()
	wm.target_highlights.clear()
	target_points.clear()
	cm = null
	wm = null
	SignalBus.update_ui_for_char.emit()

func execute() -> void:
	cm = Global.crisis_manager
	wm = Global.world_manager
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

func make_targets_unique(targets: Array) -> Array:
			var tile_set := {}
			for target in targets:
				tile_set[target] = true

			return tile_set.keys()

func resolve_with_targets(targets: Array) -> void:
	remove_invalid_points(targets)
	if targets.is_empty():
		_cleanup()
		return

	_setup_concentration()
	var shared_ctx = _build_shared_context()
	var self_ctx = _build_context(shared_ctx, user)
	#var self_ctx = _build_context(shared_ctx, user.get_coords())

	if not _has_enough_ap_and_pp(self_ctx):
		return

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				_cleanup()
				return

	SignalBus.event.emit(ReactionEvent.activity_started(self_ctx))

	for effect in self_prior_effects:
		if effect is Effect:
			if effect.has_method("apply_context"):
				effect.apply_context(self_ctx)
			else:
				effect.apply(self, self_ctx.user, self_ctx.degree)

	var final_targets = []

	match affected_type:
		Enums.Affected.ENTITIES:
			final_targets.append_array(WorldMath.get_entities_from_tiles(targets))
		Enums.Affected.TERRAIN:
			final_targets.append_array(targets)

	if can_only_hit_once:
		final_targets = make_targets_unique(final_targets)

	for final_target in final_targets:
		var ctx = _build_context(shared_ctx, final_target)
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
	_finalize_concentration(self_ctx)
	_cleanup()
	#SignalBus.dialog_show_message.emit("Activity effects released.")
	
	SignalBus.event.emit(ReactionEvent.activity_completed(self_ctx))
