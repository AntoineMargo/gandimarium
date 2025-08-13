extends HBoxContainer

var is_hovered := false
var is_pressed := false
@export var spell: Spell

func _ready():
	set_process_unhandled_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	#custom_minimum_size = Vector2(200, 40)
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	if spell:
		#$IconRect.texture = load(spell.icon)
		$NameLabel.text = spell.name
		var spell_actions = spell.activities[spell.current_index].AP_cost
		$ActionsLabel.text = "%dAP" % [spell_actions]

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			is_pressed = true
			queue_redraw()
			if event.button_index == MOUSE_BUTTON_LEFT:
				_handle_left_click()
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_handle_right_click()
		elif not event.pressed and is_pressed:
			is_pressed = false
			queue_redraw()

func _on_mouse_entered():
	print("hovered")
	is_hovered = true
	queue_redraw()

func _on_mouse_exited():
	is_hovered = false
	is_pressed = false
	queue_redraw()

func _draw():
	var color = Color(0.1, 0.1, 0.1, 0.5)
	if is_pressed:
		color = Color(0.05, 0.05, 0.05, 0.5)
	elif is_hovered:
		color = Color(0.2, 0.2, 0.2, 0.5)
	draw_rect(Rect2(Vector2.ZERO, size), color)

func _handle_left_click():
	var cm = Global.crisis_manager
	print("Left click on spell:", spell.name)
	cm.try_perform_activity(spell.activities[spell.current_index])
	#spell.activities[spell.current_index].execute(Global.selected_char, {})

func _handle_right_click():
	var um = Global.ui_manager
	print("Right click on spell:", spell.name)
	spell.cycle_activity()
	um.update_spell_list()

#func _gui_input(event):
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#_handle_left_click()
		#elif event.button_index == MOUSE_BUTTON_RIGHT:
			#_handle_right_click()

#func _pressed():
	#spell.activities[spell.current_index].execute(Global.selected_char, {})
