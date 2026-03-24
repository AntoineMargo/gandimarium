extends Control

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

@onready var spell_list = get_node_or_null("ColorRect/VBox/Tabs/Spells/HBox/Scroller/SpellList")
@onready var spell_element = preload("res://interface/all_char_info_window/available_spell.tscn")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if $ColorRect/VBox/TopBar.get_global_rect().has_point(get_global_mouse_position()):
					dragging = true
					drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func _on_exit_pressed() -> void:
	Global.all_info_window.visible = false

func _update_for_char(character: Creature):
	for child in spell_list.get_children():
		child.queue_free()

	for spell in character.data.spells_available:
		var available_spell = spell_element.instantiate()
		available_spell.spell = spell
		available_spell.character = character
		spell_list.add_child(available_spell)
		if Global.crisis_manager.crisis_mode:
			available_spell.modulate = Color(0.5, 0.5, 0.5, 1.0)
			available_spell.check_button.mouse_filter = Control.MOUSE_FILTER_IGNORE

		if character.data.major_archetype.type != Enums.Archetype.SCHOLASTIC_MAGE:
			available_spell.check_button.visible = false

func _ready() -> void:
	z_index = 2000
	mouse_filter = Control.MOUSE_FILTER_STOP
	$ColorRect/VBox/TopBar/ExitButton.pressed.connect(_on_exit_pressed)
	SignalBus.update_character_window.connect(_update_for_char)
