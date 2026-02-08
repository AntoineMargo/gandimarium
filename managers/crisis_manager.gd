extends Node
class_name CrisisManager

const CRITICAL_SUCCESS_THRESHOLD = 10
const SUCCESS_THRESHOLD = 0
const FAILURE_THRESHOLD = -10

var crisis_mode: bool = false
var crisis_round: int = 0

var initiative_order = []
var current_index: int = -1



var activity_mode: Activity = null
#var activity_user: Node = null

func forward_unhandled_input(event: InputEvent) -> void:
	if activity_mode != null:
		activity_mode.handle_input(event)

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

func try_perform_activity(activity):
	if activity.requires_crisis and not crisis_mode:
		SignalBus.dialog_show_message.emit("You are not in crisis mode!")
		return
	if not Global.focus_char:
		return
	
	if not enough_action_points_for_activity(activity):
		return
	if not enough_power_points_for_activity(activity):
		return
	Global.focus_char.perform_activity(activity)
	SignalBus.update_ui_for_char.emit()

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
		handle_next_turn()

func request_toggle_crisis(creature):

	if Global.ai_manager.active_number == 0:
		toggle_crisis(creature)
	else:
		SignalBus.dialog_show_message.emit("Cannot end crisis: there are still creatures inching for a fight.")
		print("Cannot end crisis as the following creatures are active:")
		for element in Global.ai_manager.active_creatures:
			print("%s" % element.data.name)
	SignalBus.crisis_state_changed.emit()

func toggle_crisis(creature):
	if crisis_mode == false:
		start_crisis(creature)
	else:
		end_crisis(creature)

func start_crisis(creature):
	if crisis_mode == false:
		if not Global.selected_char:
			return
		SignalBus.dialog_show_message.emit("Crisis started by %s." % creature.data.name)
		crisis_mode = true
		crisis_round = 0
		SignalBus.toggle_end_turn_button.emit()
		if creature.data.crisis_ai_active:
			SignalBus.crisis_state_changed.emit()
		SignalBus.dialog_start_crisis_mode.emit()
		SignalBus.on_start_crisis.emit()
		#SignalBus.refresh_reachable_tiles.emit()
		SignalBus.update_ui_for_char.emit()
		SignalBus.dialog_show_message.emit("Initiative order:")
		#Global.world_manager.path_preview.get_char_data()
		var count: int = 0
		for element in initiative_order:
			SignalBus.dialog_show_message.emit("%d: %s" % [count, element.data.name])
			count += 1
		handle_next_turn()

func end_crisis(creature):
	if crisis_mode == true:
		print("Crisis ended by %s." % creature.data.name)
		crisis_mode = false
		crisis_round = 0
		#initiative_order.clear()
		current_index = -1
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_end_crisis_mode.emit()
		#SignalBus.refresh_reachable_tiles.emit()
		SignalBus.update_ui_for_char.emit()
		SignalBus.clear_path_preview.emit()

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
		var current_level_table = character.data.casting_table.cost_table[character.get_stat("level") - 1]
		cost = current_level_table.spell_costs[character.data.current_spell_rank]
	else:
		cost = activity.EP_cost
	
	if character.get_stat("current_pp") < cost:
		print("Not enough power points.")
		SignalBus.dialog_show_message.emit("You don't have enough power points!")
		return false
	return true

#func active_hostiles_changed(active_creatures):
	#if active_creatures > 0:
		#start_crisis

func _ready() -> void:
	SignalBus.start_crisis_mode.connect(start_crisis)
	SignalBus.end_crisis_mode.connect(end_crisis)
	SignalBus.toggle_crisis_mode.connect(toggle_crisis)
	SignalBus.add_to_initiative.connect(_add_to_initiative_order)
	SignalBus.request_toggle_crisis.connect(request_toggle_crisis)
	#SignalBus.active_hostiles_changed.connect(active_hostiles_changed)
	SignalBus.end_crisis_turn.connect(_end_player_turn)
	SignalBus.turn_ends.connect(handle_next_turn)
	SignalBus.end_player_turn.connect(_end_player_turn)
