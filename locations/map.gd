extends Node2D
class_name Map

@export var id: String = "placeholder"

@onready var current_tile_map_layer = $level0
@onready var layers: Array[TileMapLayer] = [$level0]
@onready var map_delta: MapDelta = Global.state_manager.get_map_delta(id)


var map_ready: bool = false
var creatures: Array[Creature] = []
var props: Array[Prop] = []

#var creatures_by_uid: Dictionary[int, Creature] = {}
#var props_by_pos: Dictionary[Vector3i, Prop] = {}


func register_creature(creature: Creature):
	if creature not in creatures:
		creatures.append(creature)
		#print("creature registered: ", creature.data.name)
	else:
		print("creature ALREADY registered: ", creature.data.name)


func register_prop(prop: Prop):
	if prop not in props:
		props.append(prop)
		#print("creature registered: ", creature.data.name)
	else:
		print("prop ALREADY registered: ", prop.data.name)


func unregister_creature(creature: Creature):
	creatures.erase(creature)


func unregister_prop(prop: Prop):
	props.erase(prop)


func clear_data() -> void:
	if not creatures.is_empty():
		for creature in creatures:
			creature.destroy_self()


func creatures_only_visible_if_on_layer():
	for creature in creatures:
		creature.visible = (creature.data.tile_z == current_tile_map_layer.id)


func _ready() -> void:
	call_deferred("creatures_only_visible_if_on_layer")


#func destroy_self():
	#Global.map_manager.remove_map(id)
