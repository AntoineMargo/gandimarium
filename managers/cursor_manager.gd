extends Node
class_name CursorManager

var cursors := {}

func set_cursor(name: String):
	if name in cursors:
		Input.set_custom_mouse_cursor(cursors[name], Input.CURSOR_ARROW, Vector2(0, 0))

func _ready():
	cursors["default"] = preload("res://art/interface/cursors/36/Cursor Default.png")
	cursors["activity"] = preload("res://art/interface/cursors/36/Cursor Magic Use Blue.png")
	cursors["enemy"] = preload("res://art/interface/cursors/36/Cursor Default Enemy.png")
	cursors["friendly"] = preload("res://art/interface/cursors/36/Cursor Default Friends.png")
	cursors["select"] = preload("res://art/interface/cursors/36/Cursor Target Move B.png")
	cursors["select2"] = preload("res://art/interface/cursors/36/Cursor Attack Friends.png")
	cursors["select3"] = preload("res://art/interface/cursors/36/Cursor Attack Enemy.png")
	#cursors["other"] = preload()
	SignalBus.change_cursor.connect(set_cursor)
