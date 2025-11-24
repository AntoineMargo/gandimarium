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

	#activity.execute(Global.focus_char)
	Global.focus_char.data.perform_activity(activity)
	SignalBus.update_ui_for_char.emit()

func forward_unhandled_input(event: InputEvent) -> void:
	if activity_mode != null:
		activity_mode.handle_input(event)

func end_turn():
	if crisis_mode == true:
		crisis_turn += 1
		SignalBus.dialog_end_turn.emit()
		SignalBus.turn_ends.emit()
		SignalBus.update_ui_for_char.emit()
		SignalBus.refresh_reachable_tiles.emit()

func toggle_crisis(creature):
	if crisis_mode == false:
		start_crisis(creature)
	else:
		SignalBus.turn_ends.emit()
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

#func get_tile_data(x: int, y: int, z: int):
	#WorldMath.get_tile_data(x, y, z)

#func shape_burst(target_entities, user, range):
	#WorldMath.shape_burst(target_entities, user, range)

#func is_in_range(user: Node, target: Node, range: int):
	#WorldMath.is_in_range(user, target, range)

#func bresenham_line_3d(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int):
	#WorldMath.bresenham_line_3d(x1, y1, z1, x2, y2, z2)

#func line_of_sight_exists(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int):
	#WorldMath.line_of_sight_exists(x1, y1, z1, x2, y2, z2)
	
#func has_line_of_sight(origin_char, target_char):
	#WorldMath.has_line_of_sight(origin_char, target_char)

func _ready() -> void:
	SignalBus.start_crisis_mode.connect(start_crisis)
	SignalBus.end_crisis_mode.connect(end_crisis)
	SignalBus.end_crisis_turn.connect(end_turn)
	SignalBus.toggle_crisis_mode.connect(toggle_crisis)
