extends NumericModifier
class_name AdditionModifier

@export var to_add: int = 0

func modify(value: int, ctx: Context):
	return value + to_add
