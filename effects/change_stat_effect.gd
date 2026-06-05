extends Effect
class_name ChangeStatEffect

enum Type {
	ADD,
	REPLACE,
	MULTIPLY,
}

@export var type: Type = Type.ADD
@export var entry_containers: Array[AbstractStatEntryContainer] = []

func apply(source, target, _degree: int = 2):
	for container in entry_containers:
		var entry = container.get_entry(source, target)
		match type:
			Type.ADD:
				target.change_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
			Type.REPLACE:
				target.replace_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
			Type.MULTIPLY:
				target.multiply_stat_enum(entry.get_type(), entry.get_stat(), entry.get_amount(source, target))
