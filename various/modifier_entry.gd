extends Resource
class_name ModifierEntry

@export var stat: String = ""
@export var amount: int = 0

func get_amount(target) -> int:
	return amount
