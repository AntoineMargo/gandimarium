extends Node2D
class_name Prop

@export var prop_name: String = "placehoder"
@export var id: String = "placehoder"
@export var uid: int = -1
@export var blocks_movement: bool = true
@export var max_hp: int = 20
@export var is_runtime: bool = false

@export var physical: int = 0
@export var heat: int = 0
@export var cold: int = 0
@export var electricity: int = 0
@export var corrosion: int = 0
@export var poison: int = 0
@export var psychic: int = 0

var wm = null
var parent_layer = null

var pos: Vector3i
var current_hp: int = 0

func get_coords() -> Vector3i:
	return pos

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
	prop_delta.hp = current_hp
	return prop_delta

func take_damage(damage: int, resistance: String = ""):
	var value = get(resistance)
	var resistance_value: int = value if value is int else 0
	var final_damage = (damage - resistance_value)
	if final_damage < 0:
		final_damage = 0
	current_hp -= final_damage
	health_status_change()

func health_status_change():
	if current_hp >= max_hp:
		current_hp = max_hp
	if current_hp < 0:
		current_hp = 0
	if current_hp == 0:
		if is_runtime:
			unregister()
		wm.remove_from_tile(self, pos)
		if blocks_movement:
			var layer_coords = Vector2i(pos.x, pos.y)
			wm.layers[pos.z]["path_map"].set_point_solid(layer_coords, false)
			wm.layers[pos.z]["occupied"][layer_coords] = false
		destroy_self()

func destroy_self():
	var tilemap: TileMapLayer = get_parent()
	var coords: Vector2i = tilemap.local_to_map(global_position)
	tilemap.erase_cell(coords)

func operate():
	pass

func _ready() -> void:
	wm = Global.world_manager
	parent_layer = get_parent().get_parent()
	current_hp = max_hp
	pos = wm.pixels_to_tile(global_position, parent_layer.id)
	if wm.world_ready == true:
		_initialize()
	SignalBus.world_ready.connect(_initialize)
	SignalBus.world_quit.connect(unregister)
