extends Modifier
class_name BoolModifier

@export var replace_by: bool = true

func modify(value: bool, ctx: Context):
	value = replace_by
	return value
