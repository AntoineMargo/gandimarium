extends Node
class_name CrisisManager

const CRITICAL_SUCCESS_THRESHOLD = 10
const SUCCESS_THRESHOLD = 0
const FAILURE_THRESHOLD = -10

var crisis_mode: bool = false
var crisis_round: int = 0

var initiative_order = []
var current_index: int = -1

func _add_to_initiative_order(creature):
	if creature not in initiative_order:
		initiative_order.append(creature)
		initiative_order.sort_custom(func(a, b):
			if a.get_stat("sense") > b.get_stat("sense"):
				return true
			elif a.get_stat("sense") < b.get_stat("sense"):
				return false
			return a.get_stat("tie_breaker") > b.get_stat("tie_breaker"))
		SignalBus.dialog_show_message.emit("%s added to the initiative order." % [creature.data.name])

func remove_from_initiative_order(creature):
	if creature in initiative_order:
		initiative_order.erase(creature)
		SignalBus.dialog_show_message.emit("%s removed from the initiative order." % [creature.data.name])

func try_perform_activity(activity) -> bool:
	if activity.requires_crisis and not crisis_mode:
		SignalBus.dialog_show_message.emit("You are not in crisis mode!")
		return false
	if not Global.focus_char:
		return false
	
	if Global.crisis_manager.crisis_mode and not enough_action_points_for_activity(activity):
		return false
	if not enough_power_points_for_activity(activity):
		return false
	Global.focus_char.perform_activity(activity)
	SignalBus.update_ui_for_char.emit()
	return true

func handle_next_turn():
	if initiative_order:
		current_index += 1
		if current_index > (initiative_order.size() - 1):
			current_index = 0
			crisis_round += 1
			SignalBus.dialog_show_message.emit("Round %d has started." % crisis_round)
		initiative_order[current_index].turn_start()

func _end_player_turn():
	if crisis_mode == true:
		SignalBus.dialog_end_turn.emit()
		Global.time_manager.skip_time(0, 0, 0, 6)
		handle_next_turn()

func request_toggle_crisis(creature):
	if Global.ai_manager.active_number == 0:
		toggle_crisis(creature)
	else:
		SignalBus.dialog_show_message.emit("Cannot end crisis: there are still creatures itching for a fight.")
		print("Cannot end crisis as the following creatures are active:")
		for element in Global.ai_manager.active_creatures:
			print("%s" % element.data.name)
	SignalBus.crisis_state_changed.emit()

func toggle_crisis(creature):
	if crisis_mode == false:
		start_crisis(creature)
	else:
		end_crisis(creature)
	SignalBus.update_character_window.emit(creature)

func start_crisis(creature):
	if crisis_mode == false:
		SignalBus.stop_all_movement.emit()
		if creature:
			SignalBus.dialog_show_message.emit("Crisis started by %s." % creature.data.name)
			if creature.data.crisis_ai_active:
				SignalBus.crisis_state_changed.emit()
		crisis_mode = true
		crisis_round = 0
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_start_crisis_mode.emit()
		SignalBus.start_crisis_mode.emit(creature)
		#SignalBus.on_start_crisis.emit()
		SignalBus.update_ui_for_char.emit()
		Global.character_lock = true
		handle_next_turn()

func end_crisis(creature):
	if crisis_mode == true:
		print("Crisis ended by %s." % creature.data.name)
		crisis_mode = false
		crisis_round = 0
		#initiative_order.clear()
		current_index = -1
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.end_crisis_mode.emit(creature)
		#SignalBus.refresh_reachable_tiles.emit()
		SignalBus.update_ui_for_char.emit()
		SignalBus.clear_path_preview.emit()
		Global.character_lock = false

func enough_action_points_for_activity(activity):
	var cost = activity.AP_cost
	var character = Global.focus_char

	if character.get_stat("current_ap") < cost:
		print("Not enough action points.")
		SignalBus.dialog_show_message.emit("You don't have enough action points!")
		return false
	return true

func enough_power_points_for_activity(activity):
	var character = Global.focus_char
	var cost = 0
	if character.data.casting_table:
		cost = character.get_current_spell_cost()
	else:
		cost = activity.EP_cost
	
	if character.get_stat("current_pp") < cost:
		print("Not enough power points.")
		SignalBus.dialog_show_message.emit("You don't have enough power points!")
		return false
	return true

func _ready() -> void:
	SignalBus.start_crisis_mode.connect(start_crisis)
	#SignalBus.end_crisis_mode.connect(end_crisis)
	SignalBus.toggle_crisis_mode.connect(toggle_crisis)
	SignalBus.add_to_initiative.connect(_add_to_initiative_order)
	SignalBus.request_toggle_crisis.connect(request_toggle_crisis)
	#SignalBus.active_hostiles_changed.connect(active_hostiles_changed)
	SignalBus.end_crisis_turn.connect(_end_player_turn)
	SignalBus.turn_ends.connect(handle_next_turn)
	SignalBus.end_player_turn.connect(_end_player_turn)
