extends Effect
class_name AddCastingTableEffect

@export var table: CastingTable = null

func apply(source, target, degree: int = 2) -> void:
	var new_table = table.duplicate()
	if target.has_method("add_casting_table"):
		target.add_casting_table(new_table)
