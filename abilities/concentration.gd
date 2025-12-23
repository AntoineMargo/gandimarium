extends Resource
class_name Concentration

signal ended

var source = null
var linked_conditions: Array = []

func register_condition(condition: Condition):
	if not linked_conditions.has(condition):
		linked_conditions.append(condition)

func cancel():
	emit_signal("ended")
	linked_conditions.clear()
	if source and source.user and source.user.data.concentrations.has(self):
		source.user.remove_concentration(self)
