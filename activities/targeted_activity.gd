extends Activity
class_name TargetedActivity

@export var number_of_targets: int = 1
var number_of_targets_left = 0
var cm = null
var wm = null

func handle_hover(tile: Vector3i) -> void:
	var tiles = compute_affected_area(tile)
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	if shape == Enums.Shape.BURST:
		if not WorldMath.is_in_range(origin, tile, reach) or not WorldMath.has_line_of_sight_tile(origin, tile):
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
	origin = user.get_coords()

	if not WorldMath.is_in_range(origin, point, reach):
		SignalBus.dialog_out_of_range.emit()
		return false

	if not WorldMath.has_line_of_sight_tile(origin, point):
		SignalBus.dialog_no_line_of_sight.emit()
		return false

	return true

func select_target():
	print("number_of_targets_left: ", number_of_targets_left)
	var coords = wm.get_hovered_tile()
	if is_valid_target_point(coords):
		if targeting_type == Enums.Targeting.ENTITIES:
			if not wm.get_entity_at_pos(coords):
				SignalBus.dialog_show_message.emit("No entity there.")
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

func resolve_with_targets(targets: Array) -> void:
	if targets.is_empty():
		_cleanup()
		return

	_setup_concentration()
	var self_ctx = _build_context(user)

	var already_hit = {}

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				_cleanup()
				return

	for target in targets:
		var batch_payload: Array[Callable] = []
		var batch_ctx = _build_context(target, already_hit)
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
				ctx = _build_context(final_target, already_hit)
			else:
				ctx = _build_context(final_target)
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

			if projectile_effect:
				if projectile_batch_mode:
					for delayed_call in frozen_ctx.delayed_calls:
						batch_payload.append(delayed_call)
				else:
					projectile_effect.apply_context(frozen_ctx)
			else:
				for delayed_call in frozen_ctx.delayed_calls:
					delayed_call.call()

		if projectile_effect and not batch_payload.is_empty():
			projectile_effect.apply_context(batch_ctx)

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
