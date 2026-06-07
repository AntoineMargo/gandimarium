extends CanvasLayer

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

@onready var control = get_node_or_null("Control")
@onready var top_bar = get_node_or_null("%TopBar")
@onready var exit_button = get_node_or_null("%ExitButton")

@onready var tabs = get_node_or_null("%Tabs")

@onready var inventory_tab = get_node_or_null("%Inventory")
@onready var spells_tab = get_node_or_null("%Spells")

#@onready var spell_list = get_node_or_null("Control/ColorRect/VBox/Tabs/Spells/HBox/Scroller/SpellList")
#@onready var spell_element = preload("res://interface/all_char_info_window/available_spell.tscn")

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if visible:
					if control.get_global_rect().has_point(get_viewport().get_mouse_position()):
						Global.set_active_window(self)
					
					if top_bar.get_global_rect().has_point(get_viewport().get_mouse_position()):
						dragging = true
						drag_offset = get_viewport().get_mouse_position() - control.global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		control.global_position = get_viewport().get_mouse_position() - drag_offset

func _on_exit_pressed() -> void:
	Global.all_info_window.visible = false

func _ready() -> void:
	#control.z_index = 100
	control.mouse_filter = control.MOUSE_FILTER_STOP
	exit_button.pressed.connect(_on_exit_pressed)
	#SignalBus.update_character_window.connect(_update_for_char)
