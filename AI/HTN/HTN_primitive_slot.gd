extends Resource
class_name HTNPrimitiveSlot

@export var name: String = ""
@export var primitive_type: Enums.PrimitiveType
@export var target_type: Enums.Targeting
@export var wanted_tags: Array[Enums.Tag]
@export var unwanted_tags: Array[Enums.Tag]
@export var optional: bool = false
@export var repeatable: bool = false

var primitive: HTNPrimitive = null
var targets: Array[Vector3i]

var requirement_to: HTNPrimitiveSlot = null

var AP_cost: int = 0
var PP_cost: int = 0
var EP_cost: int = 0
var MP_cost: float = 0.0

var skip: Enums.Skip = Enums.Skip.PROCEED

func _init(p_primitive_type: Enums.PrimitiveType = Enums.PrimitiveType.DAMAGE, 
			p_target_type: Enums.Targeting = Enums.Targeting.CREATURES, 
			p_wanted_tags: Array[Enums.Tag] = [], 
			p_unwanted_tags: Array[Enums.Tag] = []) -> void:
	primitive_type = p_primitive_type
	target_type = p_target_type
	wanted_tags = p_wanted_tags
	unwanted_tags = p_unwanted_tags


#@export var primitive: HTNPrimitive

#@export var repeat_gate: RepeatGate # AP_ONLY or REQUIREMENT
#@export var Requirement: HTNRequirement

#@export var power = {
	#damage = 100,
	#heal = 0,
	#buff = 0,
	#debuff = 0,
	#control = 0,
	#movement = 0,
	#impediment = 0,
	#summon = 0,
	#utility = 0}
