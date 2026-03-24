extends HBoxContainer
class_name SpellButton

var is_hovered: bool = false
var is_pressed: bool = false
@export var spell: SpellContainer

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
	is_hovered = true
	if spell.activities[spell.current_index] is ImmediateActivity:
		spell.activities[spell.current_index].preview_area(Global.selected_char.get_coords())
	queue_redraw()

func _on_mouse_exited():
	is_hovered = false
	is_pressed = false
	if spell.activities[spell.current_index] is ImmediateActivity:
		Global.world_manager.clear_all_visualizations()
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
	print(Global.focus_char.data.current_ap)
	cm.try_perform_activity(spell.activities[spell.current_index])

func _handle_right_click():
	var um = Global.ui_manager
	print("Right click on spell:", spell.name)
	spell.cycle_activity()
	um.update_spell_list()

func _ready():
	set_process_unhandled_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	if spell:
		#$IconRect.texture = load(spell.icon)
		$NameLabel.text = spell.name
		var spell_actions = spell.activities[spell.current_index].AP_cost
		$ActionsLabel.text = "%dAP" % [spell_actions]

#func _pressed():
	#spell.activities[spell.current_index].execute(Global.focus_char, {})
