extends Resource
class_name Spell

@export var name: String
@export var description: String
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var activities = []
#@export var minimum_rank: int = 1
@export var current_index: int = 0

func get_current_activity() -> Activity:
	return activities[current_index]

func cycle_activity():
	current_index = (current_index + 1) % activities.size()
