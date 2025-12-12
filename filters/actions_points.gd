extends Filter

class_name ActionPointsFilter

func is_satisfied(target, activity):
	if not target:
		return false

	if (target.get_current_ap() - activity.AP_cost) < 0:
		SignalBus.not_enough_ap.emit()
		return false

	return true
