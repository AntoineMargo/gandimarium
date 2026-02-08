extends Effect
class_name ConditionEffect

@export var conditions: Array[Condition] = []

func apply(source, target, degree: int = 2) -> void:
	for condition in conditions:
		if condition == null:
			continue
		var instance = condition.duplicate()
		instance.concentration = source.concentration
		if target.has_method("add_condition"):
			target.add_condition_from(source, instance)
			#target.add_condition(instance)
