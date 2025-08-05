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
	user.char_data.current_actions += self.AP_cost
	for hl in wm.target_highlights:
		hl.queue_free()
	wm.target_highlights.clear()
	cm.activity_mode = null
	SignalBus.update_ui_for_char.emit()
	SignalBus.change_cursor.emit("default")

func is_valid_target(element) -> bool:
	for filter in filters:
		if not filter.is_satisfied(element, self):
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
						follow_up(user, {})
				else:
					SignalBus.dialog_show_message.emit("Invalid target.")

func execute(user, context: Dictionary) -> void:
	SignalBus.dialog_show_message.emit("Waiting for target(s) of activity...")
	var cm = Global.crisis_manager
	cm.activity_mode = self
	self.user = user
	number_of_targets_left = number_of_targets
	SignalBus.dialog_selectable_targets.emit(number_of_targets_left)
	target_entities.clear()
	target_points.clear()
	SignalBus.change_cursor.emit("select2")

func follow_up(user, context: Dictionary) -> void:
	var cm = Global.crisis_manager
	for target in target_entities:
		for filter in filters:
			if not filter.is_satisfied(target, self):
				continue

		var degree = cm.roll_hostile_activity(user, attacking_aptitude, target, defending_aptitude)

		for effect in effects:
			effect.apply(self, target, degree)
	
	SignalBus.dialog_show_message.emit("Activity effects released.")
	SignalBus.change_cursor.emit("default")

	cm.activity_mode = null
