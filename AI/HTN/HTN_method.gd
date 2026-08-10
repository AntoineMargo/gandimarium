extends Resource
class_name HTNMethod

@export var name: String = ""
@export var wanted_acts: Array[WantedAct]

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

func generate(report: TacticalReport) -> Array[PlannedAct]:
	var sequence: Array[PlannedAct] = HTNHelper.generate_sequence(self, report)
	print("Chosen sequence: ")
	for element in sequence:
		if element.activity_variant:
			print("	%s" % [element.activity_variant.activity.name])
	return sequence
	
