extends Filter

class_name RangeFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	var cm = Global.crisis_manager

	if not cm.is_in_range(activity.user, target, activity.range):
		print("filter user: ", activity.user.data.name)
		print("filter target: ", target)
		print("filter range: ", activity.range)
		SignalBus.dialog_out_of_range.emit()
		return false
	return true
