extends ModifierEntry
class_name LevelStepModifierEntry

@export var steps: Array[LevelStep] = []

func get_amount(target) -> int:
	for i in range(steps.size() - 1, -1, -1):
		var step = steps[i]
		if target.data.level >= step.min_level:
			return step.value
	return amount # default value
