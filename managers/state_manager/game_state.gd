extends Resource
class_name GameState

@export var time_state: TimeState = null
@export var uid_state: UIDState = null

@export var creatures_by_uid: Dictionary[int, Creature] = {} # uid -> Creature
@export var parties_by_uid: Dictionary[int, Party] = {} # uid -> Party
@export var props_by_uid: Dictionary[int, Prop] = {} # uid -> Prop
#@export var conditions_by_uid: Dictionary[int, Condition] = {} # uid -> Condition
@export var item_containers_by_uid: Dictionary[int, Array] = {} # uid -> Array[ItemContainer]

@export var map_states: Dictionary[String, MapState] = {} # id -> MapState


#func get_condition(uid: int) -> Condition:
	#return conditions_by_uid.get(uid)


func get_creature(uid: int) -> Creature:
	return creatures_by_uid.get(uid)


func get_party(uid: int) -> Party:
	return parties_by_uid.get(uid)


func get_prop(uid: int) -> Prop:
	return props_by_uid.get(uid)


func get_item_container(uid: int) -> ItemContainer:
	return item_containers_by_uid.get(uid)


func _init():
	if not uid_state:
		uid_state = UIDState.new()
	if not time_state:
		time_state = TimeState.new()
