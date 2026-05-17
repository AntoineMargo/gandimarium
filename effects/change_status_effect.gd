extends Effect
class_name ChangeStatusEffect

@export var modifiers: Array[StatusEntry] = []

func apply(_source, target, _degree: int = 2):
	for entry in modifiers:
		target.change_status(entry.get_type(), entry.get_value())

func remove(_source, target, _degree):
	for entry in modifiers:
		target.change_status(entry.get_type(), entry.get_value())
