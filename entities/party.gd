extends Resource
class_name Party

@export var uid: int = 0
@export var members_by_uid: Array[int] = []
@export var player_controlled: bool = false

var members_runtime: Array = []


func setup():
	if uid == 0:
		Global.state_manager.next_uid(Enums.UIDType.PARTY)

func get_uid():
	return uid


func resolve_members():
	members_runtime.clear()
	for member_uid in members_by_uid:
		var creature = Global.state_manager.get_creature_by_uid(member_uid)
		if creature:
			members_runtime.append(creature)
