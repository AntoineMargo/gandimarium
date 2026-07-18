extends Resource
class_name HTNetwork

@export var name: String = ""
@export var strategies: Array[HTNStrategy]

func choose_strategy(_report: Dictionary) -> HTNStrategy:
	return strategies[0]
