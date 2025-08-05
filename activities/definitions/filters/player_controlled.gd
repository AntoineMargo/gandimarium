extends Filter

class_name PlayerControlledFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	if not target:
		return false

	var char_data = target.char_data
	if reverse:
		return not char_data.player_controlled
	else:
		return char_data.player_controlled
