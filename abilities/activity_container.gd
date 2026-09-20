extends Resource
class_name ActivityContainer

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var activities: Array[ActivityVariant] = []

var current_index: int = 0


func get_current_activity_variant() -> ActivityVariant:
	return activities[current_index]


## Does NOT apply execution modifiers
func get_current_activity(user: Entity) -> Activity:
	return activities[current_index].produce(user)


## Applies execution modifiers
func query_current_activity(user: Entity) -> Activity:
	return activities[current_index].pre_execute(user)


func cycle_activity():
	current_index = (current_index + 1) % activities.size()
	print("current index: %d" % [current_index])


func destroy(owner: Creature):
	if owner and owner.has_method("remove_activity"):
			owner.remove_activity(self)


func _init(n: String = "", d: String = "", i: Texture2D = null, a: Array[ActivityVariant] = []):
	self.name = n
	self.description = d
	self.icon = i
	self.activities.append_array(a)
