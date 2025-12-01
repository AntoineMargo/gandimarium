extends Node
class_name EvaluatorModule

var wm = null
var creature: Creature = null
var crisis_ai: CrisisAI = null

func activity_selector(sequences, report, entries):
	for sequence in sequences:
		for act in sequence:
			if not act.activity:
				for hint in act.hints:
					if hint == "hostile_melee":
						act.activity = report["favored_melee_weapon"].strike
						act.utility = 75
						act.target_creature = report["closest_enemy"]
						
func sequence_assessor(sequences, report, entries):
	var best_sequence = null
	var best_utility: int = 0
	
	var current_utility: int
	for i in range(sequences):
		current_utility = 0
		for act in sequences[i]:
			current_utility += act.utility
		if current_utility > best_utility:
			best_sequence = sequences[i]
	
	return best_sequence

func setup(world_manager, owner_creature: Creature, ai_controller: Node):
	wm = world_manager
	creature = owner_creature
	crisis_ai = ai_controller

func _ready() -> void:
	pass
