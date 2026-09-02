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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	_update_for_char(Global.selected_char)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
