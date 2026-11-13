extends Node2D
class_name PropNode

@export var prop_id: String = ""

@onready var sprite_node: Sprite2D = $Mover/Sprite2D

var prop: Prop = null
var tilemap: TileMapLayer = null
var map: Map = null

var data: PropData:
	get:
		return prop.data if prop else _data
	set(val):
		if prop:
			prop.data = val
		_data = val

var _data: PropData = null


func handle_prop() -> void:
	if !prop:
		Global.state_manager.handle_prop_node(self)
	sprite_node.texture = data.texture
	#SignalBus.session_half_ready.emit()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap = get_parent()
	map = tilemap.get_parent()
	if data and !data.map_id:
		data.map_id = map.id
	call_deferred("handle_prop")
