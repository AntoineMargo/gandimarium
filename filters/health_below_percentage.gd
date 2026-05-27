extends Filter

class_name HealthBelowFilter

@export var threshold: float = 0.5

func is_satisfied(context: Context) -> bool:
	return context.target.health / context.target.max_health < threshold
