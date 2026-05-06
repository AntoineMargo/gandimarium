extends Resource
class_name Reaction

@export var name: String = "placeholder"
@export var id: String = "placeholder"
@export var description: String = "This is a placeholder description."
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var tags: Array[String] = []

@export var triggers: Array[Enums.EventType]
@export var activity: ActivityContainer = null

var enabled: bool = true
