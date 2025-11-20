extends Resource

class_name Item

@export var name: String
@export var description: String
@export var icon: String
@export var weight: float = 1.0
@export var value: int = 10
@export var activities = []
@export var conditions = []
@export var attack: Activity = null
