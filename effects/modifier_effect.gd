extends Effect
class_name ModifierEffect

@export var modifiers: Array[ModifierEntry] = []

func apply(source, target, degree):
	for entry in modifiers:
		target.change_stat(entry.stat, entry.get_amount(target))

func remove(source, target, degree):
	for entry in modifiers:
		target.change_stat(entry.stat, -entry.get_amount(target))

#func apply(source, target, degree: int) -> void:
	#for entry in modifiers:
		#target.change_stat(entry.stat, entry.amount)
#
#func remove(source, target, degree: int) -> void:
	#for entry in modifiers:
		#target.change_stat(entry.stat, -entry.amount)
