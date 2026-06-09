extends Activity
class_name ImmediateActivity

@export var prompt_scene: PackedScene

var prompt_instance = null

func _cleanup() -> void:
	prompt_instance.queue_free()
	SignalBus.change_cursor.emit("default")
	Global.activity_handler = null
	origin = Vector3i(0, 0, 0)
	target_points.clear()
	SignalBus.update_ui_for_char.emit()

func cancel_activity():
	SignalBus.dialog_show_message.emit("Canceling activity.")
	_cleanup()

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				pass
			MOUSE_BUTTON_RIGHT:
				cancel_activity()

func preview_area(tile):
	var wm = Global.world_manager
	var tiles = compute_affected_area(tile)
	wm.clear_visualization(wm.preview_visualized_rects, wm.preview_visualized_lines)
	wm.visualize_area(tiles, wm.preview_visualized_rects, wm.preview_visualized_lines)

func resolve_ui() -> void:
	SignalBus.dialog_show_message.emit("Waiting for player decision...")
	Global.activity_handler = self
	self.user = user
	prompt_instance = prompt_scene.instantiate()
	Global.add_child(prompt_instance)
	SignalBus.change_cursor.emit("select2")

func execute() -> void:
	_import_context()
	origin = user.get_coords()
	var pre_ctx = _build_context()
	pre_execution_bundle_modify(pre_ctx)
	if prompt_scene:
		resolve_ui()
	else:
		resolve()

func resolve() -> void:
	_setup_concentration()
	_import_context()

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

	if not _has_enough_ap_and_pp(self_ctx):
		return

	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(self_ctx):
				return
				
	SignalBus.event.emit(ReactionEvent.activity_started(self_ctx))
	
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
	target_points.clear()
	SignalBus.update_ui_for_char.emit()
	
	SignalBus.event.emit(ReactionEvent.activity_completed(self_ctx))
