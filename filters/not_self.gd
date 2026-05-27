extends Filter

class_name NotSelfFilter

func is_satisfied(context: Context) -> bool:
	if context.target == context.user:
		return false
	return true
