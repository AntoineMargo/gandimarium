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
		SignalBus.refresh_reachable_tiles.emit()

		crisis_turn += 1
		
		if Global.selected_char:
			Global.focus_char = Global.selected_char
		Global.world_manager.selection_highlight.update_selection_highlight()
		SignalBus.update_ui_for_char.emit()

func toggle_crisis(creature):
	if crisis_mode == false:
		start_crisis(creature)
	else:
		SignalBus.update_ui_for_char.emit()
		SignalBus.refresh_reachable_tiles.emit()
		end_crisis(creature)

func start_crisis(creature):
	if crisis_mode == false:
		#print("Creature triggering crisis: ", creature.data.name)
		crisis_mode = true
		crisis_turn = 0
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_start_crisis_mode.emit()
		SignalBus.on_start_crisis.emit()
		SignalBus.update_ui_for_char.emit()

func end_crisis(creature):
	if crisis_mode == true:
		crisis_mode = false
		crisis_turn = 0
		SignalBus.toggle_end_turn_button.emit()
		SignalBus.dialog_end_crisis_mode.emit()

func enough_action_points_for_activity(activity):
	var cost = activity.AP_cost
	var char = Global.focus_char

	if char.data.current_ap < cost:
		print("Not enough action points.")
		SignalBus.dialog_show_message.emit("You don't have enough action points!")
		return false
	char.data.current_ap -= cost
	return true

func _ready() -> void:
	SignalBus.start_crisis_mode.connect(start_crisis)
	SignalBus.end_crisis_mode.connect(end_crisis)
	SignalBus.end_crisis_turn.connect(end_turn)
	SignalBus.toggle_crisis_mode.connect(toggle_crisis)
