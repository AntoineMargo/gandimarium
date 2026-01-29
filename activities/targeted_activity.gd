extends Activity
class_name TargetedActivity

@export var number_of_targets: int = 1
var number_of_targets_left = 0

func handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if affected_type == Activity.AffectedType.ENTITIES:
					select_entity_target()
			MOUSE_BUTTON_RIGHT:
				cancel_activity()

func cancel_activity():
	SignalBus.dialog_show_message.emit("Canceling activity.")
	var cm = Global.crisis_manager
	var wm = Global.world_manager
	#user.data.current_ap += self.AP_cost
	for hl in wm.target_highlights:
		hl.queue_free()
	wm.target_highlights.clear()
	cm.activity_mode = null
	SignalBus.update_ui_for_char.emit()
	SignalBus.change_cursor.emit("default")

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
	var wm = Global.world_manager
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
						for hl in wm.target_highlights:
							hl.queue_free()
						wm.target_highlights.clear()
						follow_up()
				else:
					SignalBus.dialog_show_message.emit("Invalid target.")

func execute() -> void:
	SignalBus.dialog_show_message.emit("Waiting for target(s) of activity...")
	var cm = Global.crisis_manager
	cm.activity_mode = self
	self.user = user
	number_of_targets_left = number_of_targets
	SignalBus.dialog_selectable_targets.emit(number_of_targets_left)
	target_entities.clear()
	target_points.clear()
	SignalBus.change_cursor.emit("select2")

func follow_up() -> void:
	var cm = Global.crisis_manager
	for target in target_entities:
		for filter in target_filters:
			if not filter.is_satisfied(target, self):
				continue

		var user_stat = user.get_final_stat(attacking_aptitude)
		var target_stat = user.get_final_stat(defending_aptitude)
		
		var user_roll = CombatMath.standard_roll()
		var target_roll = CombatMath.standard_roll()
		var result = CombatMath.make_opposed_check(
			user_stat, user_roll,
			target_stat, target_roll)
		var degree = CombatMath.determine_degree_success(result)
		
		for effect in target_effects:
			if effect is Effect:
				effect.apply(self, target, degree)

		for effect in self_effects:
			if effect is Effect:
				effect.apply(self, user, degree)

		user.consume_ap(AP_cost)
		if is_spell:
			user.consume_pp(user.get_stat("current_spell_cost"))
		else:
			user.consume_pp(PP_cost)
	
	SignalBus.dialog_show_message.emit("Activity effects released.")
	SignalBus.change_cursor.emit("default")

	cm.activity_mode = null
	
	SignalBus.update_ui_for_char.emit()
