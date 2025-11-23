extends Node

class_name DialogManager

func _on_show_message(text):
	Global.ui_log.text += "\n%s" % [text]
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

#func _on_show_message(text):
	#var MAX_LINES = 100
	#var lines = Global.ui_log.text.split("\n")
	#lines.append(text)
#
	#if lines.size() > MAX_LINES:
		#lines = lines.slice(lines.size() - MAX_LINES, lines.size())
#
	#Global.ui_log.text = "\n".join(lines)
	#Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_hostile_activity(user, target, user_stat, target_stat, user_roll, target_roll, degree_of_success):
	var message := "%s (%d + %d) vs %s (%d + %d)" % [
		user.data.name, user_roll, user.data.get(user_stat),
		target.data.name, target_roll, target.data.get(target_stat)]
	match degree_of_success:
		0:
			message += "\nCritical failure!"
		1:
			message += "\nFailure!"
		2:
			message += "\nSuccess!"
		3:
			message += "\nCritical success!"

	Global.ui_log.text += "\n" + message
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_damage_taken(name, damage):
	Global.ui_log.text += "\n%s took %d damage." % [name, damage]
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()
	
func _on_healing_taken(name, healing):
	Global.ui_log.text += "\n%s healed %d damage." % [name, healing]
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_not_strong_enough():
	Global.ui_log.text += "\nYou're not strong enough to use this weapon."
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_out_of_range():
	Global.ui_log.text += "\nTarget out of range."
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()
	
func _on_no_line_of_sight():
	Global.ui_log.text += "\nNo line of sight to target."
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_attack_type_selected(attack_type):
	Global.ui_log.text += "\nAttack type used: %d" % [attack_type]
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_crisis_mode_starting():
	Global.ui_log.text += "\nCrisis Mode started."
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_crisis_mode_ending():
	Global.ui_log.text += "\nCrisis Mode ending."
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_turn_ending():
	Global.ui_log.text += "\nTurn Ending."
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()
	
func _on_selectable_targets(number):
	Global.ui_log.text += "\nTarget(s) to be selected: %d" % [number]
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()
	
func _crisis_mode_not_active():
	Global.ui_log.text += "\nCrisis mode is not active!"
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _not_enough_brawn():
	Global.ui_log.text += "\nYou don't have enough brawn to use this weapon!"
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()
	
func _not_enough_ap():
	Global.ui_log.text += "\nYou don't have enough AP for this activity!"
	Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _ready() -> void:
	SignalBus.dialog_show_message.connect(_on_show_message)
	
	SignalBus.dialog_selectable_targets.connect(_on_selectable_targets)
	
	SignalBus.dialog_not_strong_enough.connect(_on_not_strong_enough)
	SignalBus.dialog_out_of_range.connect(_on_out_of_range)
	SignalBus.dialog_no_line_of_sight.connect(_on_no_line_of_sight)

	SignalBus.dialog_damage_taken.connect(_on_damage_taken)
	SignalBus.dialog_healing_taken.connect(_on_healing_taken)

	SignalBus.dialog_attack_type_selected.connect(_on_attack_type_selected)
	SignalBus.dialog_hostile_activity.connect(_on_hostile_activity)
	
	SignalBus.dialog_start_crisis_mode.connect(_on_crisis_mode_starting)
	SignalBus.dialog_end_crisis_mode.connect(_on_crisis_mode_ending)
	SignalBus.dialog_end_turn.connect(_on_turn_ending)
	
	SignalBus.crisis_mode_not_active.connect(_crisis_mode_not_active)
	SignalBus.not_enough_brawn.connect(_not_enough_brawn)
	SignalBus.not_enough_ap.connect(_not_enough_ap)
