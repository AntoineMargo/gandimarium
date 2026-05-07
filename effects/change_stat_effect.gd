extends Effect
class_name ChangeStatEffect

@export var modifiers: Array[StatEntry] = []

func apply(source, target, _degree: int = 2):
	for entry in modifiers:
		target.change_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))

func remove(source, target, _degree):
	for entry in modifiers:
		target.change_stat_enum(entry.get_type(), entry.get_stat(), -entry.get_amount(source, target))
