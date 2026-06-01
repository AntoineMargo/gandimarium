extends Filter

class_name IsWeaponAttackFilter

func is_satisfied(context: Context) -> bool:
	if context is not ActivityContext:
		return false
	
	if not context.activity.weapon:
		return false
		
	return true
