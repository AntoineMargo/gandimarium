extends Resource
class_name ModifierEntry

@export var stat: String = ""
@export var amount: int = 0

func get_amount(_source, _target) -> int:
	return amount
