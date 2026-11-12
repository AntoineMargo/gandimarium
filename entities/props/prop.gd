extends Entity
class_name Prop

@export var data: PropData

var node: PropNode = null

#var initialized: bool = false


func get_uid() -> int:
	return data.uid


func get_coords() -> Vector3i:
	return data.pos


func general_setup() -> void:
	if !data:
		var data_res: PropData = Library.get_prop(node.prop_id)
		data = data_res.duplicate(true)
	if data.pos == Vector3i(-1, -1, -1):
		data.pos = Global.world_manager.pixels_to_tile(node.global_position, node.tilemap.id)
	if data.uid == 0:
		data.uid = Global.state_manager.next_uid(Enums.UIDType.PROP)
	data.current_hp = data.max_hp


## To be used when the node has been loaded into the world.
func runtime_setup() -> void:
	var pos: Vector3i = get_coords()
	var layer_coords = Vector2i(pos.x, pos.y)
	Global.world_manager.add_to_tile_contents(self, pos)
	Global.world_manager.layers[pos.z]["cover"][layer_coords] = data.cover
	if data.blocks_movement:
		Global.world_manager.layers[pos.z]["path_map"].set_point_solid(layer_coords, true)
		Global.world_manager.layers[pos.z]["occupied"][layer_coords] = true


func register() -> void:
	node.map.props.append(self)


func unregister() -> void:
	var prop_array: Array[Prop] = node.map.props
	for prop in prop_array:
		if prop.data.uid == data.uid:
			prop_array.erase(prop)


func make_delta() -> PropDelta:
	var prop_delta = PropDelta.new()
	prop_delta.id = data.id
	prop_delta.pos = data.pos
	prop_delta.hp = data.current_hp
	return prop_delta


func apply_mat_resistances():
	match data.mat:
		Enums.Mat.SOFT_WOOD:
			data.heat = -10
		Enums.Mat.HARD_WOOD:
			data.physical = 10
			data.heat = 0
			data.cold = 10
			data.electricity = 20
			data.corrosion = 10
			data.poison = 20
			data.psychic = 100


func take_damage(damage: int, resistance: Enums.Resistance):
	var value = get_resistance(resistance)
	var resistance_value: int = value if value is int else 0
	var final_damage = (damage - resistance_value)
	if final_damage < 0:
		final_damage = 0
	data.current_hp -= final_damage
	health_status_change()


func health_status_change():
	if data.current_hp >= data.max_hp:
		data.current_hp = data.max_hp
	if data.current_hp < 0:
		data.current_hp = 0
	if data.current_hp == 0:
		destroy_self()


func get_resistance(type: Enums.Resistance) -> int:
	match type:
		Enums.Resistance.NONE:
			return 0
		Enums.Resistance.PHYSICAL:
			return data.physical
		Enums.Resistance.HEAT:
			return data.heat
		Enums.Resistance.COLD:
			return data.cold
		Enums.Resistance.ELECTRICITY:
			return data.electricity
		Enums.Resistance.CORROSION:
			return data.corrosion
		Enums.Resistance.POISON:
			return data.poison
		Enums.Resistance.PSYCHIC:
			return data.psychic
	return 0


func destroy_self():
	var layer_coords = Vector2i(data.pos.x, data.pos.y)
	Global.world_manager.layers[data.pos.z]["cover"][layer_coords] = 0
	if data.blocks_movement:
		Global.world_manager.layers[data.pos.z]["path_map"].set_point_solid(layer_coords, false)
		Global.world_manager.layers[data.pos.z]["occupied"][layer_coords] = false
	Global.world_manager.remove_from_tile_contents(self, get_coords())
	if data.is_runtime:
		unregister()
	if node:
		#node.tilemap.erase_cell(layer_coords)
		node.queue_free()


func operate(_creature: Creature):
	pass


func print_info():
	var pos: Vector3i = get_coords()
	print("id: %s, pos: (%d, %d, %d)" % [data.id, pos.x, pos.y, pos.z])


#func base_ready():
	#data.map_id = data.map.id
	#data.current_hp = data.max_hp
	#if data.is_runtime == false:
		#data.pos = Global.world_manager.pixels_to_tile(node.global_position, node.parent_layer.id)
		#if data.map.map_ready == true:
			#initialize()
	#SignalBus.map_ready.connect(initialize)
	#if not components.is_empty():
		#for component in components:
			#component.setup()


#func _on_ready():
	#base_ready()

func _ready() -> void:
	pass
	#_on_ready()
