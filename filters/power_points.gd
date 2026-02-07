extends Filter

class_name PowerPointsFilter

func is_satisfied(context: ActivityContext) -> bool:
	if not context.target:
		return false

	if (context.target.get_current_pp() - context.activity.PP_cost) < 0:
		SignalBus.dialog_show_message.emit("You don't have enough PP for this activity!")
		return false

	return true
