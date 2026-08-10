extends Filter
class_name WeaponIsNotConjuredFilter

func is_satisfied(context: Context) -> bool:
	if context is not ActivityContext:
		return false
	
	if not context.activity.weapon:
		return false
		
	if context.activity.weapon.conjured:
		return false
		
	return true
