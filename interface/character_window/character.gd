extends Control

#var character: Creature = null
#
#func update(character):
	#$ColorRect/HBoxContainer/VBoxContainer/HBoxContainer/keys/Name.text = "Name: " + character.data.name



var dragging := false
var drag_offset := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Check if we clicked the title bar area
				if $ColorRect/HBoxContainer/VBoxContainer/TopBar.get_global_rect().has_point(get_global_mouse_position()):
					dragging = true
					drag_offset = get_global_mouse_position() - global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func _ready() -> void:
	z_index = 2000
	mouse_filter = Control.MOUSE_FILTER_PASS
