extends Filter

class_name HostileFilter

@export var reverse: bool = false

func is_satisfied(target, activity):
	if not target:
		return false
		
	print("target object: ", target)
	print("target name: ", target.data.name)
	
	print("self object: ", activity.user)
	print("self name: ",  activity.user.data.name)
	
	print("Hostile: ")
	for creature in activity.user.data.hostile:
		print("	creature name: ", creature.data.name)

	var data = target.data
	if reverse:
		if target in activity.user.data.hostile:
			return false
		return true
	else:
		if target in activity.user.data.hostile:
			return true
