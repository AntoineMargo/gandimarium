extends Node
class_name MovementModule

var wm: WorldManager = null
var creature: Creature = null

func movement_planner(sequences, report):
	var distance = report["favored_melee_attack"].reach
	var path = wm.path_to_target_adjacency(creature, report["closest_enemy"], distance)
	
	sequences_to_reach_location(sequences, report, path[-1])
	#var strongest_sequences = sequences_to_reach_target(sequences, report["strongest_enemy"])
	#var frailest_sequences = sequences_to_reach_target(sequences, report["frailest_enemy"])
	return sequences

func create_sequence(sequence_length):
	var sequence = []
	for i in range(sequence_length):
		var plannedact = PlannedAct.new()
		sequence.append(plannedact)
	return sequence

func sequences_to_reach_location(sequences, _report, location):
	var sequence_length = creature.data.current_ap
	var extra_mp = creature.data.current_mp
	if extra_mp:
		sequence_length += 1
	var moves_needed = 0
	var moves_to_make = 0
	var cost = 0
	var path = wm.get_multi_level_path_for_creature(creature, location)
	if not path:
		return sequences

	cost = wm.calculate_path_cost_3D_simple(path)
	# We use the extra movement points first
	moves_needed = 1 if (cost > 0 and extra_mp > 0) else 0
	cost -= extra_mp

	moves_needed += ceil(cost/creature.get_stat("max_mp"))
	moves_to_make = min(moves_needed, sequence_length)

	if moves_to_make == 0: # creature is already right next to target
		var sequence = create_sequence(sequence_length)
		for i in range(sequence_length):
			sequence[i].hints.append("hostile_melee")
		sequences.append(sequence)
		return sequences

	else: # creature needs to move towards target
		var array = []
		array.resize(sequence_length)
		array.fill(0)
		combinatorial(sequences, array, 0, moves_to_make)
		# sequences now filled with 0 and 1s and ready to have 1s turned into actual movement.

		for sequence in sequences:
			var number_of_moves = 0
			for i in range(sequence.size()):
				var act = PlannedAct.new()
				
				if sequence[i] == 1: # Movement
					number_of_moves += 1
					act.activity = Library.get_activity("move")
					
					var start_cost = (number_of_moves - 1) * creature.get_stat("max_mp")
					var target_cost = number_of_moves * creature.get_stat("max_mp")

					var start_index = wm.find_path_index_by_cost(path, start_cost)
					var target_index = wm.find_path_index_by_cost(path, target_cost)

					act.start_position = path[start_index]
					act.target_position = path[target_index]

					if number_of_moves == moves_needed: # target tile reached
						act.utility = 25
					else: # target tile not yet reached
						act.utility = 5
				else: # Free slot
					act.hints.append("free")
					if number_of_moves == moves_needed:
						act.hints.append("hostile_melee")
						act.start_position = path[-1]
						act.utility = 50
					else:
						var step_index = min(max(0, (number_of_moves) * creature.get_stat("max_mp")), path.size() - 1)
						act.start_position = path[step_index]
						act.utility = 0

				sequence[i] = act

## returns an exhaustive number of sequences that incorporate 'move' and 'empty' activities as 0s and 1s
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

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
