extends NumericModifier
class_name MultiplyModifier

@export var multiply_by: int = 1

func modify(value: int, _ctx: Context):
	return value * multiply_by
