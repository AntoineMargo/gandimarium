extends Resource
class_name WantedAct

@export var target_type: Enums.Targeting

@export var wanted_tags: Array[ActTag]
@export var unwanted_tags: Array[ActTag]

@export var optional: bool = false
@export var repeatable: bool = false

var requirement_to: PlannedAct = null

var modifies_position: bool = false
