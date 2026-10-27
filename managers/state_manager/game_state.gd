extends Resource
class_name GameState

@export var uid_state: UIDState = null
@export var creatures_by_uid: Dictionary[int, Creature] = {} # uid -> Creature
@export var parties_by_uid: Dictionary[int, Party] = {} # uid -> Party
@export var conditions_by_uid: Dictionary[int, Condition] = {} # uid -> Condition
@export var map_states: Dictionary[String, MapState] = {}
@export var time_state: TimeState = null


func get_condition(uid: int) -> Condition:
	return conditions_by_uid.get(uid)


func get_creature(uid: int) -> Creature:
	return creatures_by_uid.get(uid)


func get_party(uid: int) -> Party:
	return parties_by_uid.get(uid)

func _init():
	if not uid_state:
		uid_state = UIDState.new()
	if not time_state:
		time_state = TimeState.new()
