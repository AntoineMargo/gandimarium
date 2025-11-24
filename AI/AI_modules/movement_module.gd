extends Node
class_name MovementModule

var wm = null
var creature: Creature = null
var crisis_ai: CrisisAI = null

func movement_planner(sequences, report):
	sequences_to_reach_target(sequences, report["closest_enemy"])
	#var strongest_sequences = sequences_to_reach_target(sequences, report["strongest_enemy"])
	#var frailest_sequences = sequences_to_reach_target(sequences, report["frailest_enemy"])
	return sequences

func create_sequence(sequence_length):
	var sequence = []
	for i in range(sequence_length):
		var plannedact = PlannedAct.new()
		sequence.append(plannedact)
	return sequence

func sequences_to_reach_target(sequences, target: Creature):
	var sequence_length = creature.data.current_ap
	var mp_needed = 0
	var cost = 0
	var path = wm.path_to_target_adjacency(creature, target)
	if not path:
		return sequences

	cost = wm.calculate_path_cost_3D(path)
	mp_needed = ceil(cost/creature.data.current_mp)

	if mp_needed == 0: # creature is already right next to target
		var sequence = create_sequence(sequence_length)
		for i in range(sequence_length):
			sequence[i].hints.append("hostile_melee")
		sequences.append(sequence)
		return sequences

	else: # creature needs to move towards target
		var array = []
		array.resize(sequence_length)
		array.fill(0)
		combinatorial(sequences, array, 0, mp_needed)
		for sequence in sequences:
			var number_of_moves = 0
			for i in range(sequence.size()):
				var act = PlannedAct.new()
				
				if sequence[i] == 1: # Movement
					number_of_moves += 1
					act.activity = Library.get_activity("move")
					if number_of_moves == mp_needed:
						act.utility = 66 
						act.start_position = path[-1]
					else:
						act.utility = 33
						var step_index = min(max(0, (number_of_moves - 1) * creature.data.current_mp), path.size() - 1)
						act.start_position = path[step_index]
				else: # Free slot
					act.hints.append("free")
					if number_of_moves == mp_needed:
						act.hints.append("hostile_melee")
						act.start_position = path[-1]
					else:
						var step_index = min(max(0, (number_of_moves) * creature.data.current_mp), path.size() - 1)
						act.start_position = path[step_index]

				sequence[i] = act

func combinatorial(sequences, current, indice: int, changes_needed: int):
	if changes_needed == 0:
		sequences.append(current.duplicate())
		return 
	if indice == current.size():
		sequences.append(current.duplicate())
		return
	
	combinatorial(sequences, current, indice + 1, changes_needed)
	var new_current = current.duplicate()
	new_current[indice] = 1;
	combinatorial(sequences, new_current, indice + 1, changes_needed - 1)

func setup(world_manager, owner_creature: Creature, ai_controller: Node):
	wm = world_manager
	creature = owner_creature
	crisis_ai = ai_controller

func _ready() -> void:
	pass
