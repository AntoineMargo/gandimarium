extends Filter

class_name RangeFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	var cm = Global.crisis_manager
	if not cm.is_in_range(activity.user, target, activity.range):
		SignalBus.dialog_out_of_range.emit()
		return false
	return true
