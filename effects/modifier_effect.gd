extends Effect
class_name ModifierEffect

@export var modifiers: Array[ModifierEntry] = []

func apply(source, target, degree: int) -> void:
	for entry in modifiers:
		#target.apply_modifier(entry.stat, entry.amount)
		target.change_stat(entry.stat, entry.amount)

func remove(source, target, degree: int) -> void:
	for entry in modifiers:
		#target.remove_modifier(entry.stat, entry.amount)
		target.change_stat(entry.stat, -entry.amount)
