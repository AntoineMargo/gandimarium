extends Resource
class_name PlannedAct

@export var activity_variant: ActivityVariant = null
@export var pre_executed: Activity = null

var position: Vector3i = Vector3i(-1, -1, -1)
var targets: Array[Vector3i] = []

var modifies_position: bool = false

var AP_cost: int = 0
var PP_cost: int = 0
var EP_cost: int = 0
var MP_cost: float = 0.0

#var requirement_to: PlannedAct = null
#var skip: Enums.Skip = Enums.Skip.PROCEED
