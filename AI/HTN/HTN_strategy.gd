extends Resource
class_name HTNStrategy

@export var name: String = ""
@export var tactics: Array[HTNTactic]

func apply_tactic(report: TacticalReport) -> Array[PlannedAct]:
	for tactic in tactics:
		var result: Array[PlannedAct] = tactic.apply_method(report)
		if not result.is_empty():
			return result
	return []
