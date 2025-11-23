extends Filter
class_name CrisisModeFilter

@export var reverse: bool = false

func is_satisfied(target, activity) -> bool:
	var mode: bool = Global.crisis_manager.crisis_mode
	var satisfied: bool = mode

	if reverse:
		satisfied = not satisfied

	if not satisfied:
		SignalBus.crisis_mode_not_active.emit()

	return satisfied
