extends Node

var wm = Global.world_manager

var creature: Creature = null

func find_closest_enemy(creature) -> Creature:
	var closest_enemy: Creature = null
	var best_cost: float = INF
	for enemy in creature.data.hostile:
		var path = wm.path_to_target_adjacency(creature, enemy)
		if path:
			var cost = wm.calculate_path_cost_3D(path)
			if best_cost > cost:
				best_cost = cost
				closest_enemy = enemy
	return closest_enemy

func movement_planner():
	var closest_enemy = find_closest_enemy(creature)
	var sequences = sequences_to_reach_target(creature, closest_enemy)
#	future other submodules adding their own sequences
	return sequences

func create_sequence(sequence_length):
	var sequence = []
	for i in range(sequence_length):
		var plannedact = PlannedAct.new()
		sequence.append(plannedact)
	return sequence

#func sequences_to_reach_target(creature: Creature, target: Creature):
	#var sequence_length = creature.data.current_ap
	#var sequences = []
	#var mp_needed = 0
	#var cost = 0
	#var path = wm.path_to_target_adjacency(creature, target)
	#if not path:
		#return sequences
#
	#cost = wm.calculate_path_cost_3D(path)
	#mp_needed = ceil(cost/creature.data.current_mp)
	#var sequence = create_sequence(sequence_length)
#
	#if mp_needed == 0: # creature is already right next to target
		#sequences.append(sequence)
		#for i in range(sequence_length):
			#sequence[i].hints.append("hostile_melee")
		#return sequences
	#else: # creature needs to move towards target
		#var move_activity = Library.get_activity("move")
		#for i in range(sequence_length):
			#sequence[i].activity = move_activity
			#sequence[i].target_creature = target
			#if i == mp_needed - 1:
				#sequence[i].utility = 66
				#if i + 1 < sequence.size():
					#sequence[i + 1].start_position = path[-1]
			#else:
				#sequence[i].utility = 33
				#if i + 1 < sequence.size():
					#var step_index = min(i * creature.data.current_mp, path.size() - 1)
					#sequence[i + 1].start_position = path[step_index]
		#if mp_needed < sequence_length:
			#for i in range(mp_needed, sequence_length):
				#sequence[i].hints.append("hostile_melee")
		#sequences.append(sequence)
		#return sequences

func sequences_to_reach_target(creature: Creature, target: Creature):
	var sequence_length = creature.data.current_ap
	var sequences = []
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

	elif mp_needed == sequence_length:
		var sequence = create_sequence(sequence_length)
		var move_activity = Library.get_activity("move")
		for i in range(sequence_length):
			sequence[i].activity = move_activity
			sequence[i].target_creature = target
			sequence[i].utility = 50
		sequences.append(sequence)
		return sequences

	else: # creature needs to move towards target
		var sequence = create_sequence(sequence_length)
		var move_activity = Library.get_activity("move")
		for i in range(sequence_length):
			sequence[i].activity = move_activity
			sequence[i].target_creature = target
			if i == mp_needed - 1: # we ARE reaching the target with this activity
				sequence[i].utility = 66
				if i + 1 < sequence.size():
					sequence[i + 1].start_position = path[-1]
			else: # we are NOT reaching with this activity
				sequence[i].utility = 33
				if i + 1 < sequence.size():
					sequence[i+1].start_position = path[i*creature.data.current_mp]
		if mp_needed < sequence_length:
			for i in range(mp_needed, sequence_length):
				sequence[i].hints.append("hostile_melee")
		sequences.append(sequence)
		return sequences
