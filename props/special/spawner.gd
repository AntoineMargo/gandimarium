extends Prop
class_name SpawnerProp

@export var creature_data: String = "res://resources/creatures/data_bandit.tres"
@export var routine: String = "res://resources/routines/bandit_routine.tres"

func spawn_creature():
	Global.world_manager.spawner.spawn_character(creature_data, pos, routine, false)

func initialize() -> void:
	var layer_coords = Vector2i(pos.x, pos.y)
	wm.add_to_tile(self, pos)
	if blocks_movement:
		wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
		wm.layers[pos.z]["occupied"][layer_coords] = true
	#if is_runtime:
		#register()
	register()
	#print_info()
	spawn_creature()
	destroy_self()

func _on_ready():
	sm = Global.state_manager
	wm = Global.world_manager
	parent_layer = get_parent().get_parent()
	prop_name = "spawner"
	id = "creature_spawner"
	blocks_movement = false
	current_hp = max_hp
	if is_runtime == false:
		pos = wm.pixels_to_tile(global_position, parent_layer.id)
		if wm.world_ready == true:
			initialize()
	SignalBus.world_ready.connect(initialize)
	SignalBus.world_quit.connect(unregister)

func _ready() -> void:
	_on_ready()
