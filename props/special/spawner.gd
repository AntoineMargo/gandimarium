extends Prop
class_name SpawnerProp

@export var creature_data: String = "res://resources/creatures/data_bandit.tres"
@export var routine: String = "res://resources/routines/bandit_routine.tres"


func spawn_creature():
	Global.world_manager.spawner.spawn_creature_at_coords(creature_data, pos, map_id, routine, false)


func initialize(m: Map = null) -> void:
	#if initialized:
		#return
	if m != map:
		return
	var layer_coords = Vector2i(pos.x, pos.y)
	wm.add_to_tile_contents(self, pos)
	if blocks_movement:
		wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
		wm.layers[pos.z]["occupied"][layer_coords] = true
	register()
	if not Global.state_manager.get_map_state(map_id).initialized:
		spawn_creature()
	destroy_self()
	initialized = true


func _on_ready():
	base_ready()
	prop_name = "spawner"
	id = "creature_spawner"
	visible = false
	blocks_movement = false


func _ready() -> void:
	_on_ready()
