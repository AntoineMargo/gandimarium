extends Node

var wm = Global.world_manager

var creature: Creature = null


func movement_planner(sequences):
	reach_target_sequences(creature, target)
#	future other submodules adding their own sequences
	return sequences

func create_sequence(sequence_length):
	var sequence = []
	for i in range(sequence_length):
		var plannedact = PlannedAct.new()
		sequence.append(plannedact)
	return sequence

func reach_target_sequences(creature: Creature, target: Creature):
	var sequence_length = creature.data.current_ap
	var sequences = []
	var mp_needed = 0
	var cost = 0
	var path = wm.path_to_target_adjacency(creature, target)
	
	var move_activity = load("res://activities/activities/move.tres")
	
	if path:
		cost = wm.calculate_path_cost_3D(path)
		mp_needed = ceil(cost/creature.data.current_mp)
	
	var sequence = create_sequence(sequence_length)
	if mp_needed == 0:
		sequences.append(sequence)
		for i in range(sequence_length):
			sequence[i].hints.append("hostile_melee")
		return sequences
	else:
		for i in range(mp_needed):
			sequence[i].activity = move_activity
			sequence[i].target_creature = target
			if i == mp_needed - 1:
				sequence[i].utility = 66
				if i + 1 < sequence.size():
					sequence[i + 1].start_position = path[-1]
			else:
				sequence[i].utility = 33
				if i + 1 < sequence.size():
					var step_index = min(i * creature.data.current_mp, path.size() - 1)
					sequence[i + 1].start_position = path[step_index]
		if mp_needed < sequence_length:
			for i in range(mp_needed, sequence_length):
				sequence[i].hints.append("hostile_melee")
		sequences.append(sequence)
		return sequences
