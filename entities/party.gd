extends Resource
class_name PartyData

@export var uid: int
@export var members_by_uid: Array[int] = []
@export var player_controlled: bool = false

var members_runtime: Array = []

func resolve_members(registry):
	members_runtime.clear()
	@warning_ignore("shadowed_variable")
	for uid in members_by_uid:
		var c = registry.get(uid)
		if c:
			members_runtime.append(c)
