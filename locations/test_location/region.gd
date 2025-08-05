extends Node2D

@export var id: String = "testlocation"
@onready var current_tile_map_layer = $level0
@onready var level0 = $level0
@onready var level1 = $level1
@onready var layers: Array[TileMapLayer] = [$level0, $level1]

var creatures: Array = []

func register_creature(creature):
	creatures.append(creature)

func deferred_setup_layers():
	Global.world_manager.setup_layers()

func _ready() -> void:
	call_deferred("deferred_setup_layers")
	pass
