extends Resource
class_name Building

@export var uid: int
@export var rooms: Array[int]
@export var tiles: Array[Vector3i] # full mass

@export var owner_uid: int = -1
#@export var building_type: Enums.something
