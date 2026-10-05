extends Node
class_name MapManager

const MAP_SPACING: int = 1000

var maps: Dictionary[int, MapData] = {}
var next_map_index: int = 0

#func clear_world_container() -> void:
	#var world_container = Global.game_root.world_container
	#for child in world_container.get_children():
		#child.free()

func load_map(map_id: String) -> void:
	Global.game_session.clear_data()
	#clear_world_container()

	var new_map = Library.get_map(map_id)
	Global.game_session.world_container.add_child(new_map)
	Global.world_manager.current_world = new_map
	setup_map(new_map)
	await get_tree().process_frame
	Global.world_manager.selection_highlight.update_selection_highlight()

## Assuming we get here from something like Library.get_map(region2)
func setup_map(map: Map):
	var map_data: MapData = create_map_data(map)
	map.clear_data()
	Global.world_manager.add_map_data(map_data.root_node, map_data.layer_ids)
	#Global.world_manager.setup_ai_zones()
	Global.world_manager.determine_size(map)
	SignalBus.world_ready.emit()


func offset_layers(element: Node, offset: int) -> void:
	for child in element.get_children():
		if child is TileMapLayer:
			var child_id = child.get("id")
			if child_id:
				child.id += offset
		offset_layers(child, offset)


func create_map_data(map: Map) -> MapData:
	var new_map_data: MapData = MapData.new()

	new_map_data.id = next_map_index
	new_map_data.base_z = next_map_index * MAP_SPACING

	offset_layers(map, new_map_data.base_z)

	#var map_instance = map.instantiate()

	#Global.world_manager.current_world.add_child(map_instance)
	new_map_data.root_node = map

	for child in map.get_children():
		if child is TileMapLayer and child.get("id"):
			new_map_data.layer_ids.append(child.id)

	maps[next_map_index] = new_map_data
	next_map_index += 1

	return new_map_data


#func create_map_data(map: PackedScene) -> MapData:
	#var new_map_data: MapData = MapData.new()
#
	#new_map_data.id = next_map_index
	#new_map_data.base_z = next_map_index * MAP_SPACING
#
	#var map_instance: Node = map.instantiate()
	#offset_layers(map_instance, new_map_data.base_z)
#
	#Global.world_manager.current_world.add_child(map_instance)
	#new_map_data.root_node = map_instance
#
	#maps[next_map_index] = new_map_data
	#next_map_index += 1
#
	#return new_map_data


func transfer_creature(creature: Creature, origin_map: Map, destination_map: Map) -> void:
	origin_map.unregister_creature(creature)
	destination_map.register_creature(creature)


func remove_map(map_id: int) -> void:
	var map: MapData = maps.get(map_id)
	if map == null:
		return

	Global.world_manager.remove_map_layers(map.base_z, map.base_z + 1000)

	map.root_node.free()

	maps.erase(map_id)


func _ready() -> void:
	pass # Replace with function body.
