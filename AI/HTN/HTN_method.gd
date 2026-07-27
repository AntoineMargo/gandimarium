extends Resource
class_name HTNMethod

@export var name: String = ""
@export var wanted_acts: Array[WantedAct]

@export var base_utility: float = 50.0
@export var trait_weights: Dictionary = {
	caution = 50,
	sociality = 50,
	compassion = 50,
	dedication = 50,
	intelligence = 50,
	charisma = 50,
	ambition = 50,
	morale = 50,}
@export var requires_group_context: bool = false  # gates PullOut & others

func generate(report: TacticalReport) -> Array[PlannedAct]:
	return HTNHelper.generate_sequence(self, report)
