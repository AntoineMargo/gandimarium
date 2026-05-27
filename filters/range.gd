extends Filter

class_name RangeFilter

@export var reverse: bool = false

func is_satisfied(context: Context) -> bool:
	if not WorldMath.char_in_range(context.activity.user, context.target, context.activity.reach):
		SignalBus.dialog_out_of_range.emit()
		return false
	return true
