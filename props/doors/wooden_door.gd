extends Prop
class_name WoodenDoorProp

var sprite = null

func operate(creature: Creature):
	if Global.selected_char == creature:
		if is_active:
			SignalBus.dialog_show_message.emit("You close the door.")
			is_active = false
			blocks_movement = true
			var layer_coords = Vector2i(pos.x, pos.y)
			wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
			wm.layers[pos.z]["occupied"][layer_coords] = true
			wm.layers[pos.z]["cover"][layer_coords] = Enums.Cover.FULL
			sprite.texture = load("res://art/props/door_closed.png")
		else:
			SignalBus.dialog_show_message.emit("You open the door.")
			is_active = true
			blocks_movement = false
			var layer_coords = Vector2i(pos.x, pos.y)
			wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, false)
			wm.layers[pos.z]["occupied"][layer_coords] = false
			wm.layers[pos.z]["cover"][layer_coords] = Enums.Cover.NONE
			sprite.texture = load("res://art/props/door_open.png")

func _ready() -> void:
	is_active = false
	_on_ready()
	sprite = $Sprite2D
