extends Resource
class_name StatusEntry

@export var type: Enums.Status
@export var value: int = 0

func get_type() -> Enums.Status:
	return type

func get_value() -> int:
		return value
