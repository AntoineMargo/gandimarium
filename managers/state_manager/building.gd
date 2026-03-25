extends Resource
class_name Building

@export var uid: int
@export var rooms: Array[int]

@export var owner_uid: int = -1

# for extra spaces like courtyards, etc.
@export var extra_state: Enums.ConstructionState
@export var extra_prop_locations: Array[Vector3i]
@export var extra_value: int
#@export var building_type: Enums.something
