extends Filter

class_name SelfFilter

func is_satisfied(context: Context) -> bool:
	if context.target == context.user:
		return true
	return false
