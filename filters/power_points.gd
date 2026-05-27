extends Filter

class_name PowerPointsFilter

func is_satisfied(ctx: Context) -> bool:
	if not ctx.target:
		return false

	var result: int = 0

	if ctx.activity.is_spell:
		result = ctx.target.get_current_pp() - ctx.user.get_stat("current_spell_cost")
		if result < 0:
			SignalBus.dialog_show_message.emit("You don't have enough PP for this activity!")
			return false
	else:
		result = ctx.target.get_current_pp() - ctx.activity.PP_cost
		if result < 0:
			SignalBus.dialog_show_message.emit("You don't have enough PP for this activity!")
			return false

	return true
