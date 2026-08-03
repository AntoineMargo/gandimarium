extends Resource
class_name HTNStrategy

@export var name: String = ""
@export var tactics: Array[HTNTactic]

func apply_tactic(report: TacticalReport) -> Array[PlannedAct]:
	var best_score: int = 0
	var best_tactic: HTNTactic = null
	
	for tactic in tactics:
		var scores: Array[int] = []
		for scorer in tactic.scorers:
			scores.append(scorer.score(report))
		var final_score: int = BasicMath.get_int_average(scores)
		if final_score > best_score:
			best_score = final_score
			best_tactic = tactic
	
	if !best_tactic:
		return []
	else:
		print("Tactic chosen: %s (score: %d)" % [best_tactic.name, best_score])
		return best_tactic.apply_method(report)


#func apply_tactic(report: TacticalReport) -> Array[PlannedAct]:
	#for tactic in tactics:
		#var result: Array[PlannedAct] = tactic.apply_method(report)
		#if not result.is_empty():
			#return result
	#return []
