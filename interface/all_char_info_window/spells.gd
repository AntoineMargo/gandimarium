extends Panel

@onready var spell_list = get_node_or_null("%SpellList")

@onready var spell_element = preload("res://interface/all_char_info_window/available_spell.tscn")

func _update_for_char(creature: Creature):
	if not creature:
		return
	for child in spell_list.get_children():
		child.queue_free()

	for spell in creature.data.spells_available:
		var available_spell = spell_element.instantiate()
		available_spell.spell = spell
		available_spell.character = creature
		spell_list.add_child(available_spell)
		if Global.crisis_manager.crisis_mode:
			available_spell.modulate = Color(0.5, 0.5, 0.5, 1.0)
			available_spell.check_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label_margin = Label.new()
	spell_list.add_child(label_margin)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.update_character_window.connect(_update_for_char)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
