extends Prop
class_name Door

var sprite = null

func sync_grid_state():
	var layer_coords = Vector2i(pos.x, pos.y)

	wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, not is_active)
	wm.layers[pos.z]["occupied"][layer_coords] = not is_active
	wm.layers[pos.z]["cover"][layer_coords] = Enums.Cover.NONE if is_active else Enums.Cover.FULL

func operate(creature: Creature):
	if is_active:
		if creature == Global.selected_char:
			SignalBus.dialog_show_message.emit("You close the door.")
		else:
			var coords = creature.get_coords()
			SignalBus.dialog_show_message.emit("coords of creature closing door: (%d, %d, %d)" % [coords.x, coords.y, coords.z])
		is_active = false
		blocks_movement = true
		var layer_coords = Vector2i(pos.x, pos.y)
		wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
		wm.layers[pos.z]["occupied"][layer_coords] = true
		wm.layers[pos.z]["cover"][layer_coords] = Enums.Cover.FULL
		sprite.texture = load("res://art/props/door_closed.png")
	else:
		if creature == Global.selected_char:
			SignalBus.dialog_show_message.emit("You open the door.")
		is_active = true
		blocks_movement = false
		var layer_coords = Vector2i(pos.x, pos.y)
		wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, false)
		wm.layers[pos.z]["occupied"][layer_coords] = false
		wm.layers[pos.z]["cover"][layer_coords] = Enums.Cover.NONE
		sprite.texture = load("res://art/props/door_open.png")

func initialize() -> void:
	var layer_coords = Vector2i(pos.x, pos.y)
	wm.add_to_tile(self, pos)
	wm.layers[pos.z]["cover"][layer_coords] = cover
	if blocks_movement:
		wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
		wm.layers[pos.z]["occupied"][layer_coords] = true
	apply_mat_resistances()
	#if is_runtime:
		#register()
	Global.door_manager.register_door(self)
	register()
	#print_info()

func destroy_self():
	Global.door_manager.deregister_door(pos)
	super()

func _on_ready():
	sm = Global.state_manager
	wm = Global.world_manager
	parent_layer = get_parent().get_parent()
	current_hp = max_hp
	if is_runtime == false:
		pos = wm.pixels_to_tile(global_position, parent_layer.id)
		if wm.world_ready == true:
			initialize()
	SignalBus.world_ready.connect(initialize)
	SignalBus.world_quit.connect(unregister)

func _ready() -> void:
	is_active = false
	_on_ready()
	sprite = $Sprite2D
