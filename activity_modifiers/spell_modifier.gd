extends Resource
class_name SpellModifier

func modify_activity(activity):
	if not activity.is_spell:
		return
	
