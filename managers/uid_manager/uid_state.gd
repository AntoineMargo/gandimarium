extends Resource
class_name UIDState

@export var creature_uid: int = 0
@export var room_uid: int = 0
@export var building_uid: int = 0

func get_creature_next() -> int:
	creature_uid += 1
	return creature_uid

func get_room_next() -> int:
	room_uid += 1
	return room_uid

func get_building_next() -> int:
	building_uid += 1
	return building_uid
