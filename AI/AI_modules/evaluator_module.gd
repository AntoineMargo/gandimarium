extends Node
class_name EvaluatorModule

var wm: WorldManager = null
var creature: Creature = null

func activity_selector(sequences, report, entries):
	for sequence in sequences:
		for act in sequence:
			if not act.activity:
				for hint in act.hints:
					if hint == "hostile_melee":
						act.activity = report["favored_melee_attack"]
						act.utility = 75
						act.target_creature = report["closest_enemy"]
						choose_optimal_attack_type(act)
						
func sequence_assessor(sequences, report, entries):
	var best_sequence = null
	var best_utility: int = 0
	
	var current_utility: int
	for i in range(sequences.size()):
		current_utility = 0
		for act in sequences[i]:
			current_utility += act.utility
		if current_utility > best_utility:
			best_sequence = sequences[i]
	
	return best_sequence

func choose_optimal_attack_type(act):
	if act.target_creature.perceive_armour() is Armour:
		for attack_type in act.activity.attack_types:
			if attack_type.id == 1:
				creature.data.equipment.set_active_strike_type(0, 1)
				creature.data.equipment.set_active_strike_type(1, 1)
			if attack_type.id == 2:
				creature.data.equipment.set_active_strike_type(0, 2)
				creature.data.equipment.set_active_strike_type(1, 2)

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
