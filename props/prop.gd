extends Node2D
class_name Prop

@export var id: String = "placehoder"
@export var blocks_movement: bool = true
@export var max_hp: int = 20
@export var default_inventory = []

var wm = null
var parent_layer = null

var pos : Vector3i
var hp: int = 0
var runtime_inventory = []

func _initialize() -> void:
	wm.layers[pos.z]["path_map"].set_point_solid(Vector2i(pos.x, pos.y), true)

func _ready() -> void:
	wm = Global.world_manager
	parent_layer = get_parent().get_parent()
	hp = max_hp
	pos = wm.pixels_to_tile(global_position, parent_layer.id)
	if wm.world_ready == true:
		_initialize()
	SignalBus.world_ready.connect(_initialize)
