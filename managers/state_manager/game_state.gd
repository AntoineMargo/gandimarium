extends Resource
class_name GameState

@export var uid_state: UIDState = null
#@export var creatures_by_uid = {} # uid -> Creature
@export var creatures_by_uid: Dictionary[int, Creature] = {} # uid -> Creature
@export var map_states: Dictionary[String, MapState] = {}

func get_creature(uid: int) -> Creature:
	return creatures_by_uid.get(uid)
