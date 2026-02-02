extends Resource
class_name Activity

enum AffectedType {
	ENTITIES,
	TERRAIN,
	ENTITIES_OR_TERRAIN,
	ENTITIES_AND_TERRAIN
}

enum ShapeType {
	CIRCLE,
	CONE,
	LINE,
	CUSTOM
}

@export var name: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var AP_cost: int = 1
@export var PP_cost: int = 0
@export var EP_cost: int = 0
@export var requires_concentration: bool = false
@export var attacking_aptitude: String = "will"
@export var defending_aptitude: String = "will"
@export var reach: int = 0
@export var spread: int = 0
@export var delay: int = 0

@export var self_filters: Array[Filter] = []
@export var self_effects: Array[Effect] = []

@export var target_filters: Array[Filter] = []
@export var target_effects: Array[Effect] = []
@export var affected_type: AffectedType = AffectedType.ENTITIES
@export var shape: ShapeType = ShapeType.CIRCLE

@export var is_spell: bool = false
@export var is_constant: bool = false
@export var ai_hint: AIHint
 
var user = null
var origin: Vector2i
var concentration = null
var target_points = []
var target_entities = []

func execute() -> void:
	pass

func can_execute() -> bool:
	for filter in self_filters:
		if filter is Filter:
			if not filter.is_satisfied(user, self):
				return false
	return true

func _init():
	if ai_hint:
		ai_hint.AP_cost = AP_cost
		ai_hint.PP_cost = PP_cost
		ai_hint.EP_cost = EP_cost
		ai_hint.reach = reach
		ai_hint.spread = spread
		ai_hint.delay = delay
