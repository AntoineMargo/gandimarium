extends Resource

class_name Item

@export var name: String
@export var id: String = "placeholder"
@export var description: String
@export var icon: String
@export var weight: float = 1.0
@export var value: int = 10
@export var activities = []
@export var conditions: Array[Condition] = []
@export var can_be_removed: bool = true

@export var brawn_req_1h: int = 4
@export var brawn_req_2h: int = 2

@export var strike: Activity = null
@export var shoot: Activity = null
@export var throw: Activity = null

@export var owner = null # inventory/equipment/tile
@export var count: int = 1

func destroy():
	if owner and owner.has_method("remove_item"):
			owner.remove_item(self)
