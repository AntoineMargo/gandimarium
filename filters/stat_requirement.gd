extends Filter

class_name StatRequirementFilter

@export var stat: String = ""
@export var value: int = 0

func is_satisfied(context: Context) -> bool:
	if not context.target:
		return false

	var stat_value = context.target.data.get(stat)

	if stat_value == null:
		return false

	if typeof(stat_value) != TYPE_INT:
		return false

	return stat_value >= value
