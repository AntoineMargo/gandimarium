extends Node
class_name UIDManager

var uid_state = null

func next_uid(type: Enums.UIDType) -> int:
	if type == Enums.UIDType.CREATURE:
		return uid_state.get_creature_next()
	elif type == Enums.UIDType.ROOM:
		return uid_state.get_room_next()
	elif type == Enums.UIDType.BUILDING:
		return uid_state.get_building_next()
	push_error("Error: ID could not be successfully produced")
	return -1

func _ready() -> void:
	uid_state = UIDState.new()
