extends TargetedActivity
class_name SnakeAreaActivity

var is_dragging: bool = false
var spread_left: int = 0

#func handle_hover(_tile: Vector3i) -> void:
	#pass

func handle_hover(tile: Vector3i) -> void:
	var tiles: Array[Vector3i] = [tile]
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	if not WorldMath.is_in_range(origin, tile, reach) or not WorldMath.has_line_of_sight_tile(origin, tile):
		wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines, Color(255, 0, 0, 255))
		return
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)

func compute_affected_area(_target_location: Vector3i) -> Array[Vector3i]:
	var tiles: Array[Vector3i] = []
	return tiles

func step_toward(a: Vector3i, b: Vector3i) -> Vector3i:
	var dx = sign(b.x - a.x)
	var dy = sign(b.y - a.y)
	@warning_ignore("unused_variable")
	var dz = sign(b.z - a.z)

	# orthogonal only
	if abs(b.x - a.x) > abs(b.y - a.y):
		return a + Vector3i(dx,0,0)
	else:
		return a + Vector3i(0,dy,0)

func start_drag():
	var start_tile = wm.get_hovered_tile()
	if not is_valid_target_point(start_tile):
		return
	spread_left = spread
	target_points = [start_tile]
	is_dragging = true

func update_drag():

	if not is_dragging:
		return

	var hovered = wm.get_hovered_tile()
	var last = target_points.back()

	if hovered == Global.last_hovered_tile:
		return

	while hovered != last:

		var next = step_toward(last, hovered)
		if target_points.size() > 1 and next == target_points[target_points.size() - 2]:
			target_points.pop_back()
			spread_left += 1
			last = target_points.back()
			continue

		if spread_left <= 0:
			break

		if next in target_points:
			break

		target_points.append(next)
		spread_left -= 1
		last = next

	wm.clear_all_visualizations()
	wm.visualize_area(target_points, wm.preview_visualized_rects, wm.preview_visualized_lines)
	Global.last_hovered_tile = hovered

func end_drag():
	if not is_dragging:
		return
	
	is_dragging = false
	resolve_with_targets(target_points)

func handle_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:

			if event.pressed and not is_dragging:
				start_drag()

			elif not event.pressed and is_dragging:
				end_drag()
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
	cm = null
	wm = null
	SignalBus.update_ui_for_char.emit()

func execute() -> void:
	cm = Global.crisis_manager
	wm = Global.world_manager
	origin = user.get_coords()
	_apply_act_mods()
	if user.data.player_controlled:
		execute_player()
		Global.last_hovered_tile = Vector3i(-1,-1,-1)
	else:
		execute_ai()

func execute_ai() -> void:
	resolve_with_targets(target_points)

func execute_player() -> void:
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

func is_valid_target_point(point: Vector3i) -> bool:
	var user_coords = user.get_coords()

	if not WorldMath.is_in_range(user_coords, point, reach):
		SignalBus.dialog_out_of_range.emit()
		return false

	if not WorldMath.has_line_of_sight_tile(user_coords, point):
		SignalBus.dialog_no_line_of_sight.emit()
		return false

	return true

func make_targets_unique(targets: Array) -> Array:
			var tile_set := {}
			for target in targets:
				tile_set[target] = true

			return tile_set.keys()

func resolve_with_targets(targets: Array) -> void:
	if targets.is_empty():
		_cleanup()
		return

	_setup_concentration()
	var self_ctx = _build_context(user)

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				_cleanup()
				return

	var final_targets = []

	match affected_type:
		Enums.Affected.ENTITIES:
			final_targets.append_array(WorldMath.get_entities_from_tiles(targets))
		Enums.Affected.TERRAIN:
			final_targets.append_array(targets)

	if can_only_hit_once:
		final_targets = make_targets_unique(final_targets)

	for final_target in final_targets:
		var ctx = _build_context(final_target)
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
	_cleanup()
	#SignalBus.dialog_show_message.emit("Activity effects released.")
