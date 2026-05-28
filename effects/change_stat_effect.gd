extends Effect
class_name ChangeStatEffect

enum Type {
	ADD_DELTA,
	REPLACE,
	MULTIPLY,
}

@export var type: Type = Type.ADD_DELTA
@export var modifiers: Array[StatEntry] = []

func apply(source, target, _degree: int = 2):
	for entry in modifiers:
		match type:
			Type.ADD_DELTA:
				target.change_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
			Type.REPLACE:
				target.replace_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
			Type.MULTIPLY:
				target.multiply_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
