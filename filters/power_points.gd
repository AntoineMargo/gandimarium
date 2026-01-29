extends Filter

class_name PowerPointsFilter

func is_satisfied(target, activity):
	if not target:
		return false

	if (target.get_current_pp() - activity.PP_cost) < 0:
		SignalBus.dialog_show_message.emit("You don't have enough PP for this activity!")
		return false

	return true
