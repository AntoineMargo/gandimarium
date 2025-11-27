extends Filter

class_name RangeFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	if not WorldMath.is_in_range(activity.user, target, activity.reach):
		SignalBus.dialog_out_of_range.emit()
		return false
	return true
