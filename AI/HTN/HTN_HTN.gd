extends Resource
class_name HTNetwork

@export var name: String = ""
@export var strategies: Array[HTNStrategy]

func apply_strategy(report: Dictionary) -> Array[PlannedAct]:
	var result: Array[PlannedAct] = []
	
	if report["closest_enemy"]:
		for strategy in strategies:
			if strategy.name == "EngageEnemy":
				result = strategy.apply_tactic(report)
	else:
		# I need to make the creates non-hostile again before crisis can really be ended
		SignalBus.end_crisis_mode.emit()

	if result:
		return result
	else:
		return []
