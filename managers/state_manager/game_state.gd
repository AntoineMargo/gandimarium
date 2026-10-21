extends Resource
class_name GameState

@export var uid_state: UIDState = null
@export var creatures_by_uid: Dictionary[int, Creature] = {} # uid -> Creature
@export var parties_by_uid: Dictionary[int, Party] = {} # uid -> Party
@export var map_states: Dictionary[String, MapState] = {}
#@export var creatures_by_uid = {} # uid -> Creature


func get_creature(uid: int) -> Creature:
	return creatures_by_uid.get(uid)


func get_party(uid: int) -> Party:
	return parties_by_uid.get(uid)
