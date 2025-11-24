#@icon("res://art/interface/activities/placeholder2.png")

extends Resource
class_name Activity

enum AffectedType {
	ENTITIES,
	TERRAIN,
	ENTITIES_OR_TERRAIN,
	ENTITIES_AND_TERRAIN
}

enum AffectedShape {
	BURST,
	LINE,
	CONE,
}

@export var name: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var AP_cost: int = 1
@export var PP_cost: int = 0
@export var EP_cost: int = 0
@export var requires_concentration: bool = false
#@export var requires_opposed_roll: bool = false
@export var attacking_aptitude: String = "will"
@export var defending_aptitude: String = "will"
@export var range: int = 0
@export var reach: int = 0

@export var self_filters: Array[Filter] = []
@export var self_effects: Array[Effect] = []

@export var target_filters: Array[Filter] = []
@export var target_effects: Array[Effect] = []
@export_enum("ENTITIES", "TERRAIN", "ENTITIES_OR_TERRAIN", "ENTITIES_AND_TERRAIN")
var affected_type: int = 0
@export_enum("BURST", "LINE", "CONE")
var affected_shape: int = 0

var user = null
var origin: Vector2i
var concentration = null
var target_points = []
var target_entities = []

#var last_failure_reason: String = ""

func execute() -> void:
	pass

func can_execute() -> bool:
	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return false
	return true
