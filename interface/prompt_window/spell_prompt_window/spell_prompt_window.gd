extends PromptWindow
class_name SpellPromptWindow

func _update_for_char(creature: Creature):
	if not creature:
		return
	for child in list.get_children():
		child.queue_free()

	for spell in creature.data.spells_available:
		var spell_button = Button.new()
		spell_button.toggle_mode = true
		spell_button.text = spell.name
		list.add_child(spell_button)


#@onready var spell_element = preload("res://interface/all_char_info_window/available_spell.tscn")
#
#func _update_for_char(creature: Creature):
	#if not creature:
		#return
	#for child in list.get_children():
		#child.queue_free()
#
	#for spell in creature.data.spells_available:
		#var available_spell = spell_element.instantiate()
		#available_spell.spell = spell
		#available_spell.character = creature
		#list.add_child(available_spell)
		#if Global.crisis_manager.crisis_mode:
			#available_spell.modulate = Color(0.5, 0.5, 0.5, 1.0)
			#available_spell.check_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
#
	#var label_margin = Label.new()
	#list.add_child(label_margin)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_update_for_char(Global.selected_char)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
