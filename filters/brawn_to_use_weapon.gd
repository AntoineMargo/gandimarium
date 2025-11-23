extends Filter

class_name BrawnToUseWeaponFilter

func is_satisfied(target, activity):
	var satisfied: bool = target.data.meets_brawn_requirements()

	if not satisfied:
		SignalBus.not_enough_brawn.emit()

	return satisfied
