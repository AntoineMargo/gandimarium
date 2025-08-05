extends Filter

class_name HealthBelowFilter

@export var threshold: float = 0.5

func is_satisfied(target, activity):
	return target.health / target.max_health < threshold
