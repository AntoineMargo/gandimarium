extends Effect
class_name SpellModifierEffect

@export var modifiers: Array[SpellModifierEntry] = []

func apply(source, target, degree: int = 2):
	for entry in modifiers:
		target.change_stat(entry.stat, entry.get_amount(source, target))

func remove(source, target, degree):
	for entry in modifiers:
		target.change_stat(entry.stat, -entry.get_amount(source, target))
