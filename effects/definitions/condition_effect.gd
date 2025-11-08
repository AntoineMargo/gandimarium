extends Effect

class_name ConditionEffect

@export var conditions = []

func apply(source, target, degree: int) -> void:
	#var user = source.user
	#var result = degree
	for condition in conditions:
		if condition == null:
			continue
		var instance = condition.duplicate()
		instance.concentration = source.concentration
		if target.data.has_method("add_condition"):
			target.data.add_condition(instance)
