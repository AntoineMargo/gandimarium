extends Effect
class_name SpellModifierEffect

@export var modifiers: Array[SpellModifierEntry] = []

func apply(source, target, _degree: int = 2):
	for entry in modifiers:
		target.change_stat(entry.stat, entry.get_amount(source, target))

func remove(source, target, _degree):
	for entry in modifiers:
		target.change_stat(entry.stat, -entry.get_amount(source, target))
