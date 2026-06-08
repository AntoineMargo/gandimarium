extends Control

var dragging := false
var drag_offset := Vector2.ZERO

@onready var parent: Node = $".."

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if parent.visible:
					if get_global_rect().has_point(get_viewport().get_mouse_position()):
						Global.set_active_window(parent)
					
					if $ColorRect/VBoxContainer/TopBar.get_global_rect().has_point(get_viewport().get_mouse_position()):
						dragging = true
						drag_offset = get_viewport().get_mouse_position() - global_position
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func _ready() -> void:
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_PASS
