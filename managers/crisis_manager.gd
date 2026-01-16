extends Node
class_name CrisisManager

const CRITICAL_SUCCESS_THRESHOLD = 10
const SUCCESS_THRESHOLD = 0
const FAILURE_THRESHOLD = -10

var crisis_mode: bool = false
var crisis_turn: int = 0

var activity_mode: Activity = null
#var activity_user: Node = null

func try_perform_activity(activity):
	if not crisis_mode:
		SignalBus.dialog_show_message.emit("You are not in crisis mode!")
		return
	if not Global.focus_char:
		return
		
	if not enough_action_points_for_activity(activity):
		return

	Global.focus_char.perform_activity(activity)
	SignalBus.update_ui_for_char.emit()

func forward_unhandled_input(event: InputEvent) -> void:
	if activity_mode != null:
		activity_mode.handle_input(event)

func end_turn():
	if crisis_mode == true:
		SignalBus.dialog_end_turn.emit()
		SignalBus.turn_ends.emit()

		crisis_turn += 1
		
		if Global.selected_char:
			Global.focus_char = Global.selected_char
		Global.world_manager.selection_highlight.update_selection_highlight()
		SignalBus.update_ui_for_char.emit()
		SignalBus.refresh_reachable_tiles.emit()

func request_toggle_crisis(creature):
	if Global.ai_manager.active_number == 0:
		toggle_crisis(creature)
	SignalBus.crisis_state_changed.emit()

func toggle_crisis(creature):
	if crisis_mode == false:
		start_crisis(creature)
	else:
		end_crisis(creature)

func start_crisis(creature):
	if crisis_mode == false:
		print("Crisis started by %s." % creature.data.name)
		SignalBus.dialog_show_message.emit("Crisis started by %s." % creature.data.name)
		crisis_mode = true
		crisis_turn = 0
		SignalBus.toggle_end_turn_button.emit()
		if creature.data.crisis_ai_active:
			SignalBus.crisis_state_changed.emit()
		SignalBus.dialog_start_crisis_mode.emit()
		SignalBus.on_start_crisis.emit()
		SignalBus.refresh_reachable_tiles.emit()
		SignalBus.update_ui_for_char.emit()

func end_crisis(creature):
	if crisis_mode == true:
		print("Crisis ended by %s." % creature.data.name)
		crisis_mode = false
		crisis_turn = 0
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_end_crisis_mode.emit()
		SignalBus.refresh_reachable_tiles.emit()
		SignalBus.update_ui_for_char.emit()

func enough_action_points_for_activity(activity):
	var cost = activity.AP_cost
	var char = Global.focus_char

	if char.data.current_ap < cost:
		print("Not enough action points.")
		SignalBus.dialog_show_message.emit("You don't have enough action points!")
		return false
	char.data.current_ap -= cost
	return true

#func active_hostiles_changed(active_creatures):
	#if active_creatures > 0:
		#start_crisis

func _ready() -> void:
	SignalBus.start_crisis_mode.connect(start_crisis)
	SignalBus.end_crisis_mode.connect(end_crisis)
	SignalBus.end_crisis_turn.connect(end_turn)
	SignalBus.toggle_crisis_mode.connect(toggle_crisis)
	
	SignalBus.request_toggle_crisis.connect(request_toggle_crisis)
	#SignalBus.active_hostiles_changed.connect(active_hostiles_changed)
