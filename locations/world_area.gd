extends Node2D
class_name WorldArea

@export var id: String = "placeholder"
@onready var current_tile_map_layer = $level0
@onready var layers: Array[TileMapLayer] = [$level0]

var creatures: Array[Creature] = []
var creatures_by_id: Dictionary[int, Creature] = {}

func register_creature(creature):
	creatures.append(creature)
	creatures_by_id[creature.data.id] = creature
	print("creature registered: ", creature.data.name)

func unregister_creature(creature):
	creatures.erase(creature)
	creatures_by_id.erase(creature.data.id)

func deferred_setup_layers():
	Global.world_manager.setup_layers()
	SignalBus.world_ready.emit()
	
func _ready() -> void:
	call_deferred("deferred_setup_layers")
	pass
