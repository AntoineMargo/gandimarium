extends Resource
class_name MapState

@export var map_delta: MapDelta

# Deprecated
#@export var room_to_tiles: Dictionary[int, Array] = {}
#@export var tile_to_rooms: Dictionary[Vector3i, Array] = {}
#@export var room_to_creature: Dictionary[int, int] = {}
#@export var building_to_tiles: Dictionary[int, Array] = {}
#@export var tile_to_building: Dictionary[Vector3i, int] = {}
#@export var building_to_creature: Dictionary[int, int] = {}
#@export var room_to_building: Dictionary[int, int] = {}

@export var buildings: Dictionary[int, Building] = {}
@export var rooms: Dictionary[int, Room] = {}
@export var tile_to_rooms: Dictionary[Vector3i, Array] = {}

@export var creatures_by_uid: Dictionary = {}   # uid -> CreatureData

@export var creature_locations: Dictionary = {} # uid -> MapID or OvermapPosition

@export var parties_by_uid: Dictionary = {}     # uid -> PartyData

@export var data_dirty: bool = true

func assign_room_to_building(room_uid, building_uid):
	var room = rooms[room_uid]
	var building = buildings[building_uid]

	room.building_uid = building_uid

	if room_uid not in building.rooms:
		building.rooms.append(room_uid)




func _init():
	if not map_delta:
		map_delta = MapDelta.new()
