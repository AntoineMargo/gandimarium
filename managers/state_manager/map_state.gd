extends Resource
class_name MapState

@export var map_delta: MapDelta

@export var room_to_tiles: Dictionary[int, Array] = {}
@export var tile_to_rooms: Dictionary[Vector3i, Array] = {}
@export var room_to_creature: Dictionary[int, int] = {}

@export var building_to_tiles: Dictionary[int, Array] = {}
@export var tile_to_building: Dictionary[Vector3i, int] = {}
@export var building_to_creature: Dictionary[int, int] = {}
@export var room_to_building: Dictionary[int, int] = {}

@export var creatures_by_uid: Dictionary = {}   # uid -> CreatureData

@export var creature_locations: Dictionary = {} # uid -> MapID or OvermapPosition

@export var parties_by_uid: Dictionary = {}     # uid -> PartyData

@export var data_dirty: bool = true

func _init():
	if not map_delta:
		map_delta = MapDelta.new()
