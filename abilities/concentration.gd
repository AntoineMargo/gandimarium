extends Resource
class_name Concentration

var source = null
@export var linked_conditions: Array = []
@export var PP_cost: int = 0

func register_condition(condition: Condition):
	if not linked_conditions.has(condition):
		linked_conditions.append(condition)

func cancel():
	for condition in linked_conditions:
		if is_instance_valid(condition):
			condition.remove_source(source.id)
	linked_conditions.clear()
	if source and source.user and source.user.data.concentrations.has(self):
		source.user.remove_concentration(self)
