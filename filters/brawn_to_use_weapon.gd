extends Filter

class_name BrawnToUseWeaponFilter

func is_satisfied(context: Context) -> bool:
	var satisfied: bool = context.target.meets_brawn_requirements()

	if not satisfied:
		SignalBus.not_enough_brawn.emit()

	return satisfied
