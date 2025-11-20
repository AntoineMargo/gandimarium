extends Filter

class_name BrawnToUseWeaponFilter

func is_satisfied(target, activity):
	if not target:
		return false

	return target.meets_brawn_requirements()
