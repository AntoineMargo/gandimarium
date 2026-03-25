extends Resource
class_name Room

@export var uid: int
@export var tiles: Array[Vector3i] = []

@export var owner_uid: int = -1
@export var building_uid: int = -1

@export var state: Enums.ConstructionState
@export var room_type: Enums.RoomType
@export var prop_locations: Array[Vector3i]
@export var value: int
