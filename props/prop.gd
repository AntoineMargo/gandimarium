extends Node2D
class_name Prop

@export var prop_name: String = "placehoder"
@export var id: String = "placehoder"
@export var uid: int = -1
@export var blocks_movement: bool = true
@export var max_hp: int = 20
@export var is_runtime: bool = false

var wm = null
var parent_layer = null

var pos : Vector3i
var hp: int = 0

func _initialize() -> void:
	var layer_coords = Vector2i(pos.x, pos.y)
	wm.add_to_tile(self, pos)
	if blocks_movement:
		wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
		wm.layers[pos.z]["occupied"][layer_coords] = true
	if is_runtime:
		uid = Global.uid_manager.next_uid(UIDManager.Type.PROP)
		register()
	
func register() -> void:
	wm.add_prop_to_delta(self)

func unregister() -> void:
	wm.remove_prop_from_delta(self)

func make_delta() -> PropDelta:
	var prop_delta = PropDelta.new()
	prop_delta.uid = uid
	prop_delta.id = id
	prop_delta.pos = pos
	prop_delta.hp = hp
	return prop_delta

func operate():
	pass

func _ready() -> void:
	wm = Global.world_manager
	parent_layer = get_parent().get_parent()
	hp = max_hp
	pos = wm.pixels_to_tile(global_position, parent_layer.id)
	if wm.world_ready == true:
		_initialize()
	SignalBus.world_ready.connect(_initialize)
	#SignalBus.world_quit.connect(unregister)
