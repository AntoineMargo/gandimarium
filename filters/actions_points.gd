extends Filter

class_name ActionPointsFilter

@export var number: int = 1

func is_satisfied(target, activity):
	if not target:
		return false

	if (target.data.get_current_ap() - number) < 0:
		return false

	return true
