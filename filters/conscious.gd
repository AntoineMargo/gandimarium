extends Filter
class_name ConsciousFilter

@export var reverse: bool = false

func is_satisfied(context: ActivityContext) -> bool:
	if context.target.data.state > Enums.State.CONSCIOUS:
		if reverse:
			return true
		return false

	if reverse:
		return false
	return true
