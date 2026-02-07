extends Activity
class_name TargetedActivity

@export var number_of_targets: int = 1
var number_of_targets_left = 0
var cm = null
var wm = null

func _cleanup() -> void:
	SignalBus.change_cursor.emit("default")
	cm.activity_mode = null
	for hl in wm.target_highlights:
		hl.queue_free()
	wm.target_highlights.clear()
	cm = null
	wm = null
	SignalBus.update_ui_for_char.emit()

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if affected_type == Activity.AffectedType.ENTITIES:
					select_entity_target()
			MOUSE_BUTTON_RIGHT:
				cancel_activity()

func execute() -> void:
	cm = Global.crisis_manager
	wm = Global.world_manager
	_apply_act_mods()
	if user.data.player_controlled:
		execute_player()
	else:
		execute_ai()

func execute_ai() -> void:
	resolve_with_targets(target_entities)

func execute_player() -> void:
	SignalBus.dialog_show_message.emit("Waiting for target(s) of activity...")
	cm.activity_mode = self
	self.user = user
	number_of_targets_left = number_of_targets
	SignalBus.dialog_selectable_targets.emit(number_of_targets_left)
	target_entities.clear()
	target_points.clear()
	SignalBus.change_cursor.emit("select2")

func cancel_activity():
	SignalBus.dialog_show_message.emit("Canceling activity.")
	_cleanup()

func is_valid_target(target) -> bool:
	if not WorldMath.char_in_range(user, target, reach):
		SignalBus.dialog_out_of_range.emit()
		return false
	if not WorldMath.has_line_of_sight(user, target):
		SignalBus.dialog_no_line_of_sight.emit()
		return false
	return true

func select_entity_target():
	print("number_of_targets_left: ", number_of_targets_left)
	var coords = wm.get_tile_coords()
	if wm.layers[wm.current_level]["contents"].has(coords.vec2):
		for element in wm.layers[wm.current_level]["contents"][coords.vec2]:
			if element is Creature:
				if is_valid_target(element):
					target_entities.append(element)
					number_of_targets_left -= 1
					if number_of_targets_left > 0:
						var target_highlight = load("res://interface/target_highlight.tscn").instantiate()
						target_highlight.target = element
						wm.add_child(target_highlight)
						wm.target_highlights.append(target_highlight)
						target_highlight.update_selection_highlight()
						SignalBus.dialog_selectable_targets.emit(number_of_targets_left)
					if number_of_targets_left == 0:
						#for hl in wm.target_highlights:
							#hl.queue_free()
						#wm.target_highlights.clear()
						resolve_with_targets(target_entities)
				else:
					SignalBus.dialog_show_message.emit("Invalid target.")

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

	for target in targets:
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
	_cleanup()
	#SignalBus.dialog_show_message.emit("Activity effects released.")
