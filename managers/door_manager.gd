extends Node
class_name DoorManager

var wm = null

var doors: Array = []

var changed: Array = []

#func get_door_at(pos: Vector3i) -> WoodenDoorProp:
	#return doors.get(pos)

func register_door(door: WoodenDoorProp) -> void:
	doors.append(door)

#func prepare_doors_for_creature(_creature):
	#changed.clear()
	#
	#for door in doors:
		#var tile = door.pos
		#var layer_tile = Vector2i(tile.x, tile.y)
		#var pm = wm.layers[tile.z]["path_map"]
#
		#if pm.is_point_solid(layer_tile):
			#changed.append(door)
			#pm.set_point_solid(layer_tile, false)
#
	#return changed

func prepare_doors_for_pathfinding():
	#changed.clear()
	
	for door in doors:
		var tile = door.pos
		var layer_tile = Vector2i(tile.x, tile.y)
		var pm = wm.layers[tile.z]["path_map"]

		if pm.is_point_solid(layer_tile):
			#changed.append(door)
			pm.set_point_solid(layer_tile, false)

## Must always be used after prepare_doors_for_creature()!
#func reset_doors_to_previous_state():
	#for door in changed:
		#var tile = door.pos
		#var layer_tile = Vector2i(tile.x, tile.y)
		#var pm = wm.layers[tile.z]["path_map"]
#
		#pm.set_point_solid(layer_tile, true)

func reset_doors_to_previous_state():
	for door in doors:
			door.sync_grid_state()

func _ready() -> void:
	wm = Global.world_manager
