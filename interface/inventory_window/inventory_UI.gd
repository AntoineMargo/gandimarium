extends Control

var dragging := false
var drag_offset := Vector2.ZERO

func _input(event):
	if visible:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					# Check if we clicked the title bar area
					if $MainVBox/TopBar.get_global_rect().has_point(get_global_mouse_position()):
						dragging = true
						drag_offset = get_global_mouse_position() - global_position
				else:
					dragging = false

		elif event is InputEventMouseMotion and dragging:
			global_position = get_global_mouse_position() - drag_offset


func _on_exit_pressed() -> void:
	Global.inventory_window.visible = false

func _ready() -> void:
	z_index = 2000
	mouse_filter = Control.MOUSE_FILTER_PASS
	$"..".layer = 100
	$MainVBox/TopBar/ExitButton.pressed.connect(_on_exit_pressed)
