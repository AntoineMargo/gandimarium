extends Node
class_name StateManager

var wm = null

var game_state = null
var current_map_id = ""

func next_uid(type: Enums.UIDType) -> int:
	if type == Enums.UIDType.CREATURE:
		return game_state.uid_state.get_creature_next()
	elif type == Enums.UIDType.ROOM:
		return game_state.uid_state.get_room_next()
	elif type == Enums.UIDType.BUILDING:
		return game_state.uid_state.get_building_next()
	push_error("Error: ID could not be successfully produced.")
	return -1

func get_map_state(map_id: String) -> MapState:
	if not game_state.map_states.has(map_id):
		game_state.map_states[map_id] = MapState.new()
	return game_state.map_states[map_id]

func get_map_delta(map_id: String) -> MapDelta:
	var map_state = get_map_state(map_id)
	return map_state.map_delta

func add_prop_to_delta(prop: Prop) -> void:
	var map_delta = get_map_delta(current_map_id)
	var prop_delta = prop.make_delta()
	var key = prop.pos

	if map_delta.removed_props.has(key):
		map_delta.removed_props.erase(key)

	if map_delta.added_props.has(key):
		return
	else:
		map_delta.added_props[key] = prop_delta

func remove_prop_from_delta(prop: Prop) -> void:
	var map_delta = get_map_delta(current_map_id)
	var key = prop.pos

	if map_delta.added_props.has(key):
		map_delta.added_props.erase(key)
		return

	# Cancel modification
	if map_delta.modified_props.has(key):
		map_delta.modified_props.erase(key)

	map_delta.removed_props[key] = true

func on_prop_modified(prop: Prop) -> void:
	var map_delta = get_map_delta(current_map_id)
	var key = prop.pos

	if map_delta.added_props.has(key):
		map_delta.added_props[key] = prop.make_delta()
	else:
		map_delta.modified_props[key] = prop.make_delta()

func save_game_state():
	
	var dir_path = "res://saved/game_state/"
	var path = "%s/%s.tres" % [dir_path, "game_state"]

	var dir = DirAccess.open("res://saved/")
	if not dir.dir_exists("game_state"):
		dir.make_dir("game_state")

	var err = ResourceSaver.save(game_state, path)

	if err != OK:
		push_error("Failed to save game state: %s" % err)
	else:
		print("GAME STATE SAVED!")

func load_game_state() -> bool:
	var path = "res://saved/game_state/game_state.tres"
	
	if not ResourceLoader.exists(path):
		print("No save file found.")
		return false
	
	var loaded_resource = ResourceLoader.load(path)
	
	if loaded_resource == null:
		push_error("Failed to load game state.")
		return false
	
	if loaded_resource is not GameState:
		push_error("Loaded resource is not a GameState.")
		return false
		
	game_state = loaded_resource
	print("GAME STATE LOADED!")
	return true



const DIRS = [
	Vector3i(-1,0,0),
	Vector3i(1,0,0),
	Vector3i(0,-1,0),
	Vector3i(0,1,0),
]

func get_layer_by_id(id: int) -> TileMapLayer:
	for layer in wm.current_world.get_children():
		if layer.id == id:
			return layer
	return null

func add_rooms_to_state_in_map(map_id: String, start_layer_id: int) -> void:
	var map_state: MapState = get_map_state(map_id)
	var current_layer_id: int = start_layer_id
	var current_layer: TileMapLayer = get_layer_by_id(start_layer_id)

	if _add_rooms_to_state_in_layer(map_state, current_layer):
		while true:
			current_layer_id += 1
			current_layer = get_layer_by_id(current_layer_id)
			if not current_layer or not _add_rooms_to_state_in_layer(map_state, current_layer):
				break

		current_layer_id = start_layer_id

		while true:
			current_layer_id -= 1
			current_layer = get_layer_by_id(current_layer_id)
			if not current_layer or not _add_rooms_to_state_in_layer(map_state, current_layer):
				break
		
		print("Rooms found and added to state!")

func _add_rooms_to_state_in_layer(map_state: MapState, layer: TileMapLayer) -> bool:
	var layer_has_rooms: bool = false
	var tile_to_rooms = map_state.tile_to_rooms

	for x in range(wm.map_width):
		for y in range(wm.map_height):
			var start_tile: Vector3i = Vector3i(x, y, layer.id)
			var tile_data = layer.get_cell_tile_data(Vector2i(x, y))

			if tile_data \
			and tile_data.get_custom_data("inside") == true \
			and tile_data.get_custom_data("cover") == 0:

				var prop = wm.get_prop_at_pos(start_tile)

				if not tile_to_rooms.has(start_tile) and not (prop is Door):
					_add_room_to_state(map_state, layer, start_tile)
					layer_has_rooms = true

	return layer_has_rooms

func _add_room_to_state(map_state: MapState, layer: TileMapLayer, start_tile: Vector3i) -> void:
	var room_tiles: Array[Vector3i] = _flood_room(layer, start_tile)

	if room_tiles.is_empty():
		return

	var room_uid = next_uid(Enums.UIDType.ROOM)

	var room: Room = Room.new()
	room.uid = room_uid
	room.tiles = room_tiles
	room.owner_uid = -1
	room.building_uid = -1
	room.state = Enums.ConstructionState.INTACT
	room.room_type = Enums.RoomType.UNDEFINED
	room.prop_locations = []
	room.value = 0

	map_state.rooms[room_uid] = room

	for tile in room_tiles:
		var tile_data = layer.get_cell_tile_data(Vector2i(tile.x, tile.y))
		if not tile_data:
			continue

		var cover = tile_data.get_custom_data("cover")

		if cover == 0:
			# floor tiles are exclusive
			map_state.tile_to_rooms[tile] = [room_uid]
		else:
			# wall tiles can be shared
			if not map_state.tile_to_rooms.has(tile):
				map_state.tile_to_rooms[tile] = []
			map_state.tile_to_rooms[tile].append(room_uid)

func _flood_room(chosen_layer, start_tile: Vector3i) -> Array[Vector3i]:
	var start_data = chosen_layer.get_cell_tile_data(Vector2i(start_tile.x, start_tile.y))
	if not start_data or start_data.get_custom_data("cover") != 0:
		return []
	
	var stack = [start_tile]
	var visited: Dictionary[Vector3i, bool] = {}
	var result: Array[Vector3i] = []

	while stack.size() > 0:
		var tile = stack.pop_back()

		if visited.has(tile):
			continue
		visited[tile] = true

		var tile_2d: Vector2i = Vector2i(tile.x, tile.y)
		var tile_data = chosen_layer.get_cell_tile_data(tile_2d)
		if not tile_data:
			continue

		if not tile_data.get_custom_data("inside"):
			continue

		var cover = tile_data.get_custom_data("cover")
		var prop = wm.get_prop_at_pos(tile)

		if cover == 0:
			result.append(tile)

			if prop is Door:
				continue

			for dir in DIRS:
				stack.append(tile + dir)

		elif cover > 0:
			result.append(tile)

	return result

func _setup_map_state():
	if Global.world_manager.current_world:
		current_map_id = Global.world_manager.current_world.id
	var map_state = get_map_state(current_map_id)
	if map_state.data_dirty:
		add_rooms_to_state_in_map(current_map_id, 0)

func _ready():
	wm = Global.world_manager
	if not load_game_state():
		push_warning("USING NEW GAME STATE!")
		game_state = GameState.new()
		if not game_state.uid_state:
			game_state.uid_state = UIDState.new()
	SignalBus.world_ready.connect(_setup_map_state)
