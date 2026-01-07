extends Resource
class_name TacticalRelationEntry

@export var target_id: String

@export_range(0, 100, 1) var hostile: int = 0
@export_range(0, 100, 1) var fearful: int = 0
@export_range(0, 100, 1) var suspicious: int = 0
@export_range(0, 100, 1) var cooperative: int = 0
@export_range(0, 100, 1) var protective: int = 0

@export var last_updated_turn: int = 0
@export var source_id: String = ""
@export var reason: String = ""
