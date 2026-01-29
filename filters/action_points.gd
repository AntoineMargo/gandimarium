extends Filter

class_name ActionPointsFilter

func is_satisfied(target, activity):
	if not target:
		return false

	if (target.get_current_ap() - activity.AP_cost) < 0:
		SignalBus.dialog_show_message.emit("You don't have enough AP for this activity!")
		return false

	return true
