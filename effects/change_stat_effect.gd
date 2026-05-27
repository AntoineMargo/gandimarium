extends Effect
class_name ChangeStatEffect

enum Type {
	MODIFY,
	REPLACE
}

@export var type: Type = Type.MODIFY
@export var modifiers: Array[StatEntry] = []

func apply(source, target, _degree: int = 2):
	for entry in modifiers:
		if Type.MODIFY:
			target.change_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
		elif Type.REPLACE:
			target.replace_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))

#func remove(source, target, _degree):
	#pass
	#for entry in modifiers:
		#target.change_stat_enum(entry.get_type(), entry.get_stat(), -entry.get_amount(source, target))
