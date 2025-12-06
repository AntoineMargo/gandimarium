extends Resource

class_name Item

@export var name: String
@export var description: String
@export var icon: String
@export var weight: float = 1.0
@export var value: int = 10
@export var activities = []
@export var conditions: Array[Condition] = []

@export var brawn_req_1h : int = 4
@export var brawn_req_2h : int = 2

@export var strike: Activity = null
@export var shoot: Activity = null
@export var throw: Activity = null
