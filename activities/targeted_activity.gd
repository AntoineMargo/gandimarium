extends Activity
class_name TargetedActivity

@export var number_of_targets: int = 1
var number_of_targets_left = 0
var cm = null
var wm = null

func handle_hover(tile: Vector3i) -> void:
	var tiles = compute_affected_area(tile)
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
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

func select_target():
	print("number_of_targets_left: ", number_of_targets_left)
	var coords = wm.get_hovered_tile()
	if is_valid_target_point(coords):
		if targeting_type == Enums.Targeting.ENTITIES:
			if not wm.find_creature_on_tile(coords):
				SignalBus.dialog_show_message.emit("No creature there.")
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

	for target in targets:
		var affected_tiles = compute_affected_area(target)
		
		match affected_type:
			Enums.Affected.ENTITIES:
				final_targets.append_array(WorldMath.get_creatures_from_tiles(affected_tiles))
			Enums.Affected.TERRAIN:
				final_targets.append_array(affected_tiles)
	
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
