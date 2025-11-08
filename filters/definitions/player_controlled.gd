extends Filter

class_name PlayerControlledFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	if not target:
		return false

	var data = target.data
	if reverse:
		return not data.player_controlled
	else:
		return data.player_controlled
