extends Node

class_name DialogManager

const MAX_LINES = 200
var lines: Array[String] = []

func add_log(text: String):
	lines.append(text)

	if lines.size() > MAX_LINES:
		lines.pop_front()  # remove oldest line

	Global.ui_log.text = "\n".join(lines)

func _on_show_message(text):
	add_log(text)

func _on_hostile_activity(user, target, user_stat, target_stat, user_roll, target_roll, degree_of_success):
	pass
	#var message := "%s (%d + %d) vs %s (%d + %d)" % [
		#user.data.name, user_roll, user.data.get(user_stat),
		#target.data.name, target_roll, target.data.get(target_stat)]
	#match degree_of_success:
		#0:
			#message += "\nCritical failure!"
		#1:
			#message += "\nFailure!"
		#2:
			#message += "\nSuccess!"
		#3:
			#message += "\nCritical success!"
#
	#Global.ui_log.text += "\n" + message
	#Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_damage_taken(name, damage):
	add_log("%s took %d damage." % [name, damage])
	
func _on_healing_taken(name, healing):
	add_log("%s healed %d damage." % [name, healing])

func _on_selectable_targets(number):
	add_log("Target(s) to be selected: %d" % [number])

func _on_out_of_range():
	_on_show_message("Target out of range.")
	
func _on_no_line_of_sight():
	_on_show_message("No line of sight to target.")

func _on_crisis_mode_starting():
	_on_show_message("Crisis Mode started.")

func _on_crisis_mode_ending():
	_on_show_message("Crisis Mode ending.")

func _on_turn_ending():
	_on_show_message("Turn Ending.")

func _crisis_mode_not_active():
	_on_show_message("Crisis mode is not active!")

func _not_enough_brawn():
	_on_show_message("You don't have enough brawn to use this weapon!")
	
func _not_enough_ap():
	_on_show_message("You don't have enough AP for this activity!")

func _ready() -> void:
	SignalBus.dialog_show_message.connect(_on_show_message)
	
	SignalBus.dialog_selectable_targets.connect(_on_selectable_targets)
	
	SignalBus.dialog_out_of_range.connect(_on_out_of_range)
	SignalBus.dialog_no_line_of_sight.connect(_on_no_line_of_sight)

	SignalBus.dialog_damage_taken.connect(_on_damage_taken)
	SignalBus.dialog_healing_taken.connect(_on_healing_taken)

	SignalBus.dialog_hostile_activity.connect(_on_hostile_activity)
	
	SignalBus.dialog_start_crisis_mode.connect(_on_crisis_mode_starting)
	SignalBus.dialog_end_crisis_mode.connect(_on_crisis_mode_ending)
	SignalBus.dialog_end_turn.connect(_on_turn_ending)
	
	SignalBus.crisis_mode_not_active.connect(_crisis_mode_not_active)
	SignalBus.not_enough_brawn.connect(_not_enough_brawn)
	#SignalBus.not_enough_ap.connect(_not_enough_ap)
