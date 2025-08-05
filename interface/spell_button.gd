extends Button

@export var spell: Spell

func _ready():
	if spell:
		var spell_actions = spell.activities[spell.current_index].AP_cost
		#self.icon = load(spell.icon)
		var name: String = "%s" % [spell.name]
		#var name: String = "%s" % ["Nuclear Winter"]
		var action_points: String = "[%dAP]" % [spell_actions]
		var total_text: String = name.rpad(16) + action_points
		self.text = total_text

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_handle_right_click()

func _handle_left_click():
	var cm = Global.crisis_manager
	print("Left click on spell:", spell.name)
	cm.try_perform_activity(spell.activities[spell.current_index])
	#spell.activities[spell.current_index].execute(Global.selected_char, {})

func _handle_right_click():
	print("Right click on spell:", spell.name)
	spell.cycle_activity()
	Global.ui_manager.update_spell_list()

#func _pressed():
	#spell.activities[spell.current_index].execute(Global.selected_char, {})
