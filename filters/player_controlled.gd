extends Filter

class_name PlayerControlledFilter

@export var reverse: bool = false

func is_satisfied(context: ActivityContext) -> bool:
	if not context.target:
		return false

	var data = context.target.data
	if reverse:
		return not data.player_controlled
	else:
		return data.player_controlled
