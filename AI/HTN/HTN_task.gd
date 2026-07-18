extends Resource
class_name HTNStrategy

@export var name: String = ""
@export var tactics: Array[HTNTactic]

func choose_tactic(_report: Dictionary) -> HTNTactic:
	return tactics[0]
