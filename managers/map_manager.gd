extends Node
class_name MapManager

const MAP_SPACING: int = 1000

var next_map_index: int = 0

var maps: Dictionary[int, MapData] = {}
var current_map_index: int = 0


func change_map() -> void:
	var next_map: Map = get_next_map()
	var next_layer_track: Array[int] = get_current_map_layer_ids()
	Global.world_manager.change_map(next_map, next_layer_track)


## Takes the index (usually 0 1 2 or 3) and returns the corresponding map.
func get_map_from_index(index: int) -> Map:
	return maps[index].root


func get_current_map_layer_ids() -> Array[int]:
	return maps[current_map_index].layer_ids


func get_next_map() -> Map:
	current_map_index += 1
	if current_map_index >= maps.size():
		current_map_index = 0
	return maps[current_map_index].root


func load_map(map_id: String) -> MapData:
	var new_map = Library.get_map(map_id)
	Global.game_session.world_container.add_child(new_map)
	var map_data: MapData = setup_map(new_map)
	if not Global.world_manager.current_map:
		Global.world_manager.current_map = new_map
		Global.world_manager.layer_track = get_current_map_layer_ids()
	return map_data


## Assuming we get here from something like Library.get_map("region2")
func setup_map(map: Map) -> MapData:
	var map_data: MapData = create_map_data(map)
	map.clear_data()
	Global.world_manager.add_map_data(map_data.root, map_data.layer_ids)
	#Global.world_manager.setup_ai_zones()
	Global.world_manager.determine_size(map)
	SignalBus.world_ready.emit()
	return map_data


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

	new_map_data.root = map

	for child in map.get_children():
		if child is TileMapLayer and child.get("id"):
			new_map_data.layer_ids.append(child.id)

	maps[next_map_index] = new_map_data
	next_map_index += 1

	return new_map_data


func transfer_creature(creature: Creature, origin_map: Map, destination_map: Map) -> void:
	origin_map.unregister_creature(creature)
	destination_map.register_creature(creature)


func remove_map(map_id: int) -> void:
	var map: MapData = maps.get(map_id)
	if map == null:
		return

	Global.world_manager.remove_map_layers(map.base_z, map.base_z + 1000)

	map.root.free()

	maps.erase(map_id)


func _ready() -> void:
	pass # Replace with function body.
