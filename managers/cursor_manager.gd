extends Node
class_name CursorManager

var cursors := {}

func set_cursor(cursor_name: String):
	if cursor_name in cursors:
		Input.set_custom_mouse_cursor(cursors[cursor_name], Input.CURSOR_ARROW, Vector2(0, 0))

func _ready():
	cursors["default"] = preload("res://art/interface/cursors/abstract/default.png")
	cursors["activity"] = preload("res://art/interface/cursors/abstract/fleur.png")
	cursors["enemy"] = preload("res://art/interface/cursors/abstract/fleur.png")
	cursors["friendly"] = preload("res://art/interface/cursors/abstract/help.png")
	cursors["select"] = preload("res://art/interface/cursors/abstract/help.png")
	cursors["select2"] = preload("res://art/interface/cursors/abstract/help.png")
	cursors["select3"] = preload("res://art/interface/cursors/abstract/help.png")
	#cursors["other"] = preload()
	SignalBus.change_cursor.connect(set_cursor)
