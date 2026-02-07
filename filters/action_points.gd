extends Filter

class_name ActionPointsFilter

func is_satisfied(context: ActivityContext) -> bool:
	if not context.target:
		return false

	if (context.target.get_current_ap() - context.activity.AP_cost) < 0:
		SignalBus.dialog_show_message.emit("You don't have enough AP for this activity!")
		return false

	return true
