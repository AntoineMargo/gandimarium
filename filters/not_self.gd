extends Filter

class_name NotSelfFilter

func is_satisfied(context: ActivityContext) -> bool:
	if context.target == context.origin:
		return false
	return true
