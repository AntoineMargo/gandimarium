extends Resource
class_name UIDState

@export var creature_uid: int = 0

@export var map_prop_uid: Dictionary = {}
@export var map_tile_uid: Dictionary = {}

func get_creature_next() -> int:
	creature_uid += 1
	return creature_uid

#func get_prop_next(map_id: String) -> int:
	#if map_prop_uid.has(map_id):
		#map_prop_uid[map_id] += 1
	#else:
		#map_prop_uid[map_id] = 1
	#return map_prop_uid[map_id]
#
#func get_tile_next(map_id: String) -> int:
	#if map_tile_uid.has(map_id):
		#map_tile_uid[map_id] += 1
	#else:
		#map_tile_uid[map_id] = 1
	#return map_tile_uid[map_id]

#func set_prop_next(map_id: String, uid: int) -> void:
		#map_prop_uid[map_id] = uid
#
#func set_tile_next(map_id: String, uid: int) -> void:
		#map_tile_uid[map_id] = uid
