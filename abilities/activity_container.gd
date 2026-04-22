extends Resource
class_name ActivityContainer

@export var name: String
@export var description: String
@export var icon: String = "res://art/interface/activities/placeholder1.png"
@export var activities: Array[ActivityVariant] = []

var current_index: int = 0

func get_current_activity_variant() -> ActivityVariant:
	return activities[current_index]
	
func get_current_activity(user: Entity) -> Activity:
	return activities[current_index].produce(user)

func cycle_activity():
	current_index = (current_index + 1) % activities.size()
	print("current index: %d" % [current_index])
