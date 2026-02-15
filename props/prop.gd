extends Node2D
class_name Prop

@export var prop_id: String = "placehoder"
@export var blocks_movement: bool = true
@export var max_hp: int = 20
@export var default_inventory = []

var wm = null
var parent_layer = null

var tile_pos : Vector3i
var hp: int = 0
var runtime_inventory = []

func _initialize() -> void:
	wm.layers[tile_pos.z]["path_map"].set_point_solid(Vector2i(tile_pos.x, tile_pos.y), true)

func _ready() -> void:
	wm = Global.world_manager
	parent_layer = get_parent().get_parent()
	hp = max_hp
	tile_pos = wm.pixels_to_tile(global_position, parent_layer.id)
	if wm.world_ready == true:
		_initialize()
	SignalBus.world_ready.connect(_initialize)
