extends NumericModifier
class_name ReplaceModifier

@export var replace_by: int = 1

func modify(_value: int, _ctx: Context):
	return replace_by
