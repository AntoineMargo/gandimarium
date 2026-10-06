extends Node2D
class_name Map

@export var id: String = "placeholder"
@onready var current_tile_map_layer = $level0
@onready var layers: Array[TileMapLayer] = [$level0]
@onready var map_delta = Global.state_manager.get_map_delta(id)

var creatures: Array[Creature] = []
var creatures_by_id: Dictionary[int, Creature] = {}


func register_creature(creature: Creature):
	creatures.append(creature)
	creatures_by_id[creature.data.uid] = creature
	print("creature registered: ", creature.data.name)


func unregister_creature(creature: Creature):
	creatures.erase(creature)
	creatures_by_id.erase(creature.data.uid)

func clear_data() -> void:
	if not creatures.is_empty():
		for creature in creatures:
			creature.destroy_self()


func creatures_only_visible_if_on_layer():
	for creature in creatures:
		creature.visible = (creature.data.tile_z == current_tile_map_layer.id)


func _ready() -> void:
	call_deferred("creatures_only_visible_if_on_layer")
