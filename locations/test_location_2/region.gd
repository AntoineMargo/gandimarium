extends Node2D

@export var id: String = "testlocation2"
@onready var current_tile_map_layer = $level0
@onready var level0 = $level0
@onready var level1 = $level1
@onready var layers: Array[TileMapLayer] = [$level0, $level1]
@onready var map_delta = Global.world_manager.get_map_delta(id)

var creatures: Array = []
var creatures_by_id: Dictionary = {}

func register_creature(creature):
	creatures.append(creature)
	creatures_by_id[creature.data.id] = creature

func unregister_creature(creature):
	creatures.erase(creature)
	creatures_by_id.erase(creature.data.id)

func deferred_setup_layers():
	Global.world_manager.setup_layers()

func _ready() -> void:
	call_deferred("deferred_setup_layers")
	pass
