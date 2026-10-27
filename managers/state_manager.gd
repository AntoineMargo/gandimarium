extends Node
class_name StateManager

var wm = null

var game_state: GameState = null
#var current_map_id = ""


func next_uid(type: Enums.UIDType) -> int:
	if type == Enums.UIDType.CREATURE:
		return game_state.uid_state.get_creature_next()
	elif type == Enums.UIDType.ROOM:
		return game_state.uid_state.get_room_next()
	elif type == Enums.UIDType.BUILDING:
		return game_state.uid_state.get_building_next()
	elif type == Enums.UIDType.PARTY:
		return game_state.uid_state.get_party_next()
	elif type == Enums.UIDType.CONDITION:
		return game_state.uid_state.get_condition_next()
	elif type == Enums.UIDType.ITEM:
		return game_state.uid_state.get_item_next()
	push_error("Error: ID could not be successfully produced.")
	return -1


func register_creature(creature: Creature) -> void:
	if not game_state:
		return
	var uid: int = creature.get_uid()
	var existing: Creature = game_state.get_creature(uid)
	if existing:
		return
	game_state.creatures_by_uid[uid] = creature


func register_party(party: Party) -> void:
	if not game_state:
		return
	var uid: int = party.get_uid()
	var existing: Party = game_state.get_party(uid)
	if existing:
		return
	game_state.parties_by_uid[uid] = party


func get_creature_by_uid(uid: int) -> Creature:
	return game_state.get_creature(uid)


func get_party_by_uid(uid: int) -> Party:
	return game_state.get_party(uid)


func register_map(map: Map) -> void:
	var map_state: MapState = get_map_state(map.id)
	map_state.creature_uids.clear()
	for creature in map.creatures:
		var uid: int = creature.get_uid()
		map_state.creature_uids.append(uid)


func get_game_state() -> GameState:
	return game_state


func get_map_state(map_id: String) -> MapState:
	if not game_state:
		push_warning("No game state!")
		return null
	if not game_state.map_states.has(map_id):
		game_state.map_states[map_id] = MapState.new()
	return game_state.map_states[map_id]


func get_map_delta(map_id: String) -> MapDelta:
	var map_state = get_map_state(map_id)
	if !map_state:
		return null
	var map_delta: MapDelta = map_state.map_delta
	if map_delta:
		return map_delta
	else:
		return null


func get_propdelta_from_propref(prop_ref: PropRef) -> PropDelta:
	var map_delta: MapDelta = get_map_delta(prop_ref.map_id)
	return map_delta.added_props.get(prop_ref.pos)


func add_prop_to_delta(prop: Prop) -> void:
	var map_delta = get_map_delta(prop.map_id)
	var prop_delta = prop.make_delta()
	var key = prop.pos

	if map_delta.removed_props.has(key):
		map_delta.removed_props.erase(key)

	if map_delta.added_props.has(key):
		return
	else:
		map_delta.added_props[key] = prop_delta
		#print("Prop added to delta.")


func remove_prop_from_delta(prop: Prop) -> void:
	var map_delta = get_map_delta(prop.map.id)
	var key = prop.pos

	if map_delta.added_props.has(key):
		map_delta.added_props.erase(key)
		return

	# Cancel modification
	if map_delta.modified_props.has(key):
		map_delta.modified_props.erase(key)

	map_delta.removed_props[key] = true


func on_prop_modified(prop: Prop) -> void:
	var map_delta = get_map_delta(prop.map.id)
	var key = prop.pos

	if map_delta.added_props.has(key):
		map_delta.added_props[key] = prop.make_delta()
	else:
		map_delta.modified_props[key] = prop.make_delta()


#const SAVE_DIR: String = "user://saved/game_state"
const SAVE_DIR: String = "res://saved/game_state"
const SAVE_PREFIX: String = "game_state_"
const MAX_SAVES: int = 10


func save_time() -> void:
	var time: Vector4i = Global.time_manager.get_time()
	var time_state: TimeState = game_state.time_state
	
	time_state.days = time[0]
	time_state.hours = time[1]
	time_state.minutes = time[2]
	time_state.seconds = time[3]


func save_game_state() -> bool:
	save_time()
	
	for map in Global.map_manager.get_all_maps():
		register_map(map)

	var err = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if err != OK:
		push_error("Failed to create save directory: %s" % err)
		return false

	var path = "%s/%s%d.tres" % [SAVE_DIR, SAVE_PREFIX, int(Time.get_unix_time_from_system())]
	err = ResourceSaver.save(game_state, path)
	if err != OK:
		push_error("Failed to save game state: %s" % err)
		return false

	print("GAME STATE SAVED: ", ProjectSettings.globalize_path(path))
	_prune_old_saves()
	return true


func _list_saves() -> Array[String]:
	var saves: Array[String] = []
	for file in DirAccess.get_files_at(SAVE_DIR):
		if file.begins_with(SAVE_PREFIX) and file.ends_with(".tres"):
			saves.append(file)
	saves.sort()  # oldest first
	return saves


func _prune_old_saves() -> void:
	var saves = _list_saves()
	while saves.size() > MAX_SAVES:
		DirAccess.remove_absolute(SAVE_DIR + "/" + saves.pop_front())


func load_time() -> void:
	var time: TimeState = game_state.time_state
	Global.time_manager.set_time(time.days, time.hours, time.minutes, time.seconds)


func load_game_state() -> bool:
	var saves = _list_saves()
	if saves.is_empty():
		print("No save file found.")
		return false

	var path = SAVE_DIR + "/" + saves.back()
	var loaded = ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE)
	if loaded is not GameState:
		push_error("Failed to load a GameState from %s" % path)
		return false

	game_state = loaded
	print("GAME STATE LOADED: ", path)
	
	load_time()
	return true


const DIRS = [
	Vector3i(-1,0,0),
	Vector3i(1,0,0),
	Vector3i(0,-1,0),
	Vector3i(0,1,0),
]

const DIRS_3D = [
	Vector3i(-1,0,0),
	Vector3i(1,0,0),
	Vector3i(0,-1,0),
	Vector3i(0,1,0),
	Vector3i(0,0,-1),
	Vector3i(0,0,1)
]


func get_layer_by_id(id: int) -> TileMapLayer:
	for layer in wm.current_map.get_children():
		if layer.id == id:
			return layer
	return null


func build_buildings(map_id: String) -> void:
	var map_state: MapState = get_map_state(map_id)
	for room_uid in map_state.rooms:
		var room = map_state.rooms[room_uid]

		if room.building_uid != -1:
			continue

		_create_building_from_room(map_state, room_uid)


func _create_building_from_room(map_state: MapState, original_room_uid: int) -> void:
	var building_uid = next_uid(Enums.UIDType.BUILDING)

	var building: Building = Building.new()
	building.uid = building_uid
	building.rooms = []

	var visited: Dictionary[Vector3i, bool] = {}
	var stack: Array[Vector3i] = []
	var building_tiles = building.tiles

	# We start the building by appending a single tile from a room
	stack.append(map_state.rooms[original_room_uid].tiles[0])

	while stack.size() > 0:
		var tile: Vector3i = stack.pop_back()

		if visited.has(tile):
			continue
		visited[tile] = true

		var tile_data = wm.get_tile_data(tile)
		if not tile_data or not tile_data.get_custom_data("constructed"):
			continue

		building_tiles.append(tile)

		for dir in DIRS_3D:
			stack.append(tile + dir)

	map_state.buildings[building_uid] = building
	add_all_rooms_to_building(map_state, building)


func add_all_rooms_to_building(map_state: MapState, building: Building):

	var perimeter_uid = next_uid(Enums.UIDType.ROOM)

	var perimeter: Room = Room.new()
	perimeter.uid = perimeter_uid
	perimeter.owner_uid = -1
	perimeter.building_uid = building.uid
	perimeter.state = Enums.ConstructionState.INTACT
	perimeter.room_type = Enums.RoomType.PERIMETER
	perimeter.prop_locations = []
	perimeter.value = 0

	var added_rooms: Dictionary[int, bool] = {}

	for tile in building.tiles:
		if not map_state.tile_to_rooms.has(tile):
			perimeter.tiles.append(tile)
			map_state.tile_to_rooms[tile] = [perimeter_uid]
		else:
			for room_uid in map_state.tile_to_rooms[tile]:
				var room = map_state.rooms[room_uid]

				if room.building_uid == -1:
					room.building_uid = building.uid

				if not added_rooms.has(room_uid):
					added_rooms[room_uid] = true
					building.rooms.append(room_uid)

	if not perimeter.tiles.is_empty():
		map_state.rooms[perimeter_uid] = perimeter
		building.rooms.append(perimeter_uid)


func build_rooms(map_id: String, start_layer_id: int) -> void:
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


func _add_rooms_to_state_in_layer(map_state: MapState, layer: TileMapLayer) -> bool:
	var layer_has_rooms: bool = false
	var tile_to_rooms = map_state.tile_to_rooms

	for x in range(wm.map_width):
		for y in range(wm.map_height):
			var start_tile: Vector3i = Vector3i(x, y, layer.id)
			var tile_data = layer.get_cell_tile_data(Vector2i(x, y))

			if tile_data \
			and tile_data.get_custom_data("constructed") == true \
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

		if not tile_data.get_custom_data("constructed"):
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


func apply_delta(map: Map , map_state: MapState) -> void:
	if !map_state.map_delta:
		return

	var added_props = map_state.map_delta.added_props.values()
	for prop_delta in added_props:
		var prop: Prop = Library.get_prop(prop_delta.id)
		if !prop:
			continue
		prop.pos = prop_delta.pos
		prop.map = map
		prop.map_id = map.id
		prop.current_hp = prop_delta.hp
		prop.is_runtime = true
		Global.world_manager.spawn_prop(prop)


## Called by the map_manager on loading a map.
func load_map_state(map: Map):
	var map_id: String = map.id
	var map_state: MapState = get_map_state(map_id)
	if map_state.data_dirty:
		var default_layer: int = 500
		build_rooms(map_id, default_layer)
		build_buildings(map_id)
		print("Rooms and buildings added to state.")
		map_state.data_dirty = false
	
	if map_state.initialized:
		for creature_uid in map_state.creature_uids:
			var creature: Creature = get_creature_by_uid(creature_uid)
			if creature:
				Global.world_manager.spawner.spawn_creature(creature)
		
		apply_delta(map, map_state)


func create_new_game_state() -> void:
	game_state = GameState.new()
	if not game_state.uid_state:
		game_state.uid_state = UIDState.new()
	if not game_state.time_state:
		game_state.time_state = TimeState.new()


func _ready():
	wm = Global.world_manager
	if load_game_state():
		print("Loaded previous game.")
	else:
		create_new_game_state()
		print("Starting new game.")
