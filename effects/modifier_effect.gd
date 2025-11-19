extends Effect

class_name ModifierEffect

@export var modifiers: Dictionary

func apply(source, target, degree: int) -> void:
	for stat in modifiers.keys():
		target.apply_modifier(stat, modifiers[stat])

func remove(source, target, degree: int) -> void:
	for stat in modifiers.keys():
		target.remove_modifier(stat, modifiers[stat])
