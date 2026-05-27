extends Filter

class_name HostileFilter

@export var reverse: bool = false

func is_satisfied(context: Context) -> bool:
	if not context.target:
		return false
		
	print("target object: ", context.target)
	print("target name: ", context.target.data.name)
	
	print("self object: ", context.activity.user)
	print("self name: ",  context.activity.user.data.name)
	
	print("Hostile: ")
	for creature in context.activity.user.data.hostile:
		print("	creature name: ", creature.data.name)

	var data = context.target.data
	if reverse:
		if context.target in context.activity.user.data.hostile:
			return false
		return true
	else:
		if context.target in context.activity.user.data.hostile:
			return true
	return true
