extends PromptWindow
class_name SpellPromptWindow

var chosen_spell: Activity = null

func _update_for_char(creature: Creature):
	if not creature:
		return
	for child in list.get_children():
		child.queue_free()

	var spell_button_group = ButtonGroup.new()
	for spell in creature.data.spells_available:
		var spell_instance: SpellContainer = spell.duplicate(true)
		add_spell_button(spell_instance, spell_button_group)


func _on_spell_selected(spell: SpellContainer) -> void:
	chosen_spell = spell.query_current_activity(user)
	return


func add_spell_button(spell: SpellContainer, button_group: ButtonGroup) -> void:
	if spell:
		var button = Button.new()
		var button_activity = spell.query_current_activity(user)

		var spell_actions = button_activity.AP_cost
		var button_text: String = button_activity.name + " - %dAP" % [spell_actions]

		button.text = button_text
		button.toggle_mode = true
		button.button_group = button_group

		button.gui_input.connect(_on_spell_button_gui_input.bind(spell, button))
		button.pressed.connect(_on_spell_selected.bind(spell))
		list.add_child(button)


func _on_spell_button_gui_input(event: InputEvent, spell: SpellContainer, button: Button) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			spell.cycle_activity()
			var button_activity = spell.query_current_activity(user)
			
			var spell_actions = button_activity.AP_cost
			var button_text: String = button_activity.name + " - %dAP" % [spell_actions]
			
			button.text = button_text


#func add_spell_button(spell: SpellContainer, button_group: ButtonGroup) -> void:
	#var button = Button.new()
	#button.text = spell.name
	#button.toggle_mode = true
	#button.button_group = button_group
#
	#button.pressed.connect(_on_spell_selected.bind(spell))
#
	#list.add_child(button)


func finish() -> void:
	finished.emit({"chosen_spell" = chosen_spell})


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_update_for_char(Global.selected_char)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
