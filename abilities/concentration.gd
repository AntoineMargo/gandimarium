extends Resource
class_name Concentration

signal ended

var source = null
@export var linked_conditions: Array = []

func register_condition(condition: Condition):
	if not linked_conditions.has(condition):
		linked_conditions.append(condition)

func cancel():
	for condition in linked_conditions:
		if is_instance_valid(condition):
			condition.remove_source(source.id)
