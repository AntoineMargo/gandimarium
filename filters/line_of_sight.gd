extends Filter

class_name LineOfSightFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	var cm = Global.crisis_manager
	if not cm.has_line_of_sight(activity.user, target):
		SignalBus.dialog_no_line_of_sight.emit()
		return false
	return true
