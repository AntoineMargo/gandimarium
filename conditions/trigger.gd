extends Resource
class_name Trigger

@export var event_filters: Array[Filter] = []
@export var effects: Array[Effect] = []

func check(event: ReactionEvent) -> bool:
	for filter in event_filters:
		if not filter.is_satisfied(event.context):
			return false
	return true
