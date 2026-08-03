extends Resource
class_name HTNTactic

@export var name: String = ""
@export var methods: Array[HTNMethod] = []

@export var scorers: Array[TaskScorer] = []
@export var trait_weights: Dictionary[String, float] = {
	caution = 1.0,
	sociality = 1.0,
	compassion = 1.0,
	dedication = 1.0,
	intelligence = 1.0,
	charisma = 1.0,
	ambition = 1.0,
	morale = 1.0,}
@export var requires_group_context: bool = false  # gates PullOut & others

func apply_method(report: TacticalReport) -> Array[PlannedAct]:
	var best_score: int = 0
	var best_method: HTNMethod = null
	
	for method in methods:
		var scores: Array[int] = []
		for scorer in method.scorers:
			scores.append(scorer.score(report))
		var final_score: int = BasicMath.get_int_average(scores)
		if final_score > best_score:
			best_score = final_score
			best_method = method
	
	if !best_method:
		return []
	else:
		print("Method chosen: %s" % [best_method.name])
		return best_method.generate(report)
