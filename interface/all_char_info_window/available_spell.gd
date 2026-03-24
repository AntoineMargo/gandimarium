extends Control
class_name AvailableSpell

@onready var check_button: CheckButton = $HBoxContainer/CheckButton

@export var character: Creature
@export var spell: SpellContainer

func _on_toggled(pressed: bool) -> void:
	var ready_spells = character.data.spells_ready

	if pressed:
		if ready_spells.size() >= character.data.max_spells_ready:
			check_button.button_pressed = false
			return

		character.add_ready_spell(spell)
	else:
		character.remove_ready_spell(spell)
	SignalBus.update_ui_for_char.emit()

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	if spell:
		$HBoxContainer/Label.text = spell.name

	if not character or not spell:
		return

	check_button.button_pressed = spell in character.data.spells_ready
	check_button.toggled.connect(_on_toggled)
