extends Filter

class_name LineOfSightFilter

@export var reverse: bool = false

func is_satisfied(context: ActivityContext) -> bool:
	if not WorldMath.has_line_of_sight(context.activity.user, context.target):
		SignalBus.dialog_no_line_of_sight.emit()
		return false
	return true
