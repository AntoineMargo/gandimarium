extends HBoxContainer
class_name SpellButton

var is_hovered: bool = false
var is_pressed: bool = false

@onready var label = get_node_or_null("NameLabel")
@export var spell: SpellContainer

var user: Entity = null
var final_activity: Activity = null

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
	if final_activity is ImmediateActivity:
		final_activity.preview_area(Global.selected_char.get_coords())
	queue_redraw()

func _on_mouse_exited():
	is_hovered = false
	is_pressed = false
	if final_activity is ImmediateActivity:
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
	var um = Global.ui_manager
	if Global.activity_handler:
		spell.cycle_activity()
		final_activity = spell.get_current_activity(user)
		um.update_spell_list()
		Global.activity_handler.cancel_activity()
	cm.try_perform_activity(final_activity)

func _handle_right_click():
	var cm = Global.crisis_manager
	var um = Global.ui_manager
	spell.cycle_activity()
	final_activity = spell.get_current_activity(user)
	um.update_spell_list()
	if Global.activity_handler:
		Global.activity_handler.cancel_activity()
		cm.try_perform_activity(final_activity)

func _ready():
	set_process_unhandled_input(true)
	mouse_filter = Control.MOUSE_FILTER_STOP
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	if spell:
		final_activity = spell.get_current_activity(user)
		var button_activity = spell.query_current_activity(user)
		#$IconRect.texture = load(final_activity.icon)
		$NameLabel.text = button_activity.name
		var spell_actions = button_activity.AP_cost
		$ActionsLabel.text = "%dAP" % [spell_actions]

#func _pressed():
	#spell.activities[spell.current_index].execute(Global.focus_char, {})
