extends Node
class_name MovementModule

var wm: WorldManager = null
var creature: Creature = null

func movement_planner(sequences, report):
	sequences_to_reach_target(sequences, report)
	#var strongest_sequences = sequences_to_reach_target(sequences, report["strongest_enemy"])
	#var frailest_sequences = sequences_to_reach_target(sequences, report["frailest_enemy"])
	return sequences

func create_sequence(sequence_length):
	var sequence = []
	for i in range(sequence_length):
		var plannedact = PlannedAct.new()
		sequence.append(plannedact)
	return sequence

func sequences_to_reach_target(sequences, report):
	print("=== sequences_to_reach_target ===")
	var sequence_length = creature.data.current_ap
	var moves_needed = 0
	var moves_to_make = 0
	var cost = 0
	var target = report["closest_enemy"]
	print("target: ", target.data.name)
	print("favored_melee_attack: ", report["favored_melee_attack"].name)
	var distance = report["favored_melee_attack"].reach
	var path = wm.path_to_target_adjacency(creature, target, distance)
	if not path:
		return sequences

	cost = wm.calculate_path_cost_3D_simple(path)
	moves_needed = ceil(cost/creature.get_stat("max_mp"))
	moves_to_make = min(moves_needed, sequence_length)
		
	print("creature.data.max_mp: ", creature.get_stat("max_mp"))
	print("path.size(): ", path.size())
	print("cost: ", cost)
	print("moves_needed: ", moves_to_make)

	if moves_to_make == 0: # creature is already right next to target
		print("CHARACTER ALREADY NEXT TO TARGET")
		var sequence = create_sequence(sequence_length)
		for i in range(sequence_length):
			sequence[i].hints.append("hostile_melee")
		sequences.append(sequence)
		return sequences

	else: # creature needs to move towards target
		print("CHARACTER WILL NEED TO MOVE TO TARGET")
		var array = []
		array.resize(sequence_length)
		array.fill(0)
		combinatorial(sequences, array, 0, moves_to_make)
		for sequence in sequences:
			print("NEW SEQUENCE:")
			var number_of_moves = 0
			for i in range(sequence.size()):
				var act = PlannedAct.new()
				
				if sequence[i] == 1: # Movement
					print("	CHARACTER MOVES TOWARDS TARGET")
					number_of_moves += 1
					act.activity = Library.get_activity("move")
					
					var start_cost = (number_of_moves - 1) * creature.get_stat("max_mp")
					var target_cost = number_of_moves * creature.get_stat("max_mp")

					var start_index = wm.find_path_index_by_cost(path, start_cost)
					var target_index = wm.find_path_index_by_cost(path, target_cost)

					act.start_position = path[start_index]
					act.target_position = path[target_index]

					print("act.start_position: ", act.start_position)
					print("act.target_position: ", act.target_position)
					print("number_of_moves: ", number_of_moves)

					if number_of_moves == moves_needed: # target tile reached
						act.utility = 25
					else: # target tile not yet reached
						act.utility = 5
				else: # Free slot
					print("	CHARACTER STANDS STILL")
					act.hints.append("free")
					if number_of_moves == moves_needed:
						print("		CHARACTER ATTACKS TARGET")
						act.hints.append("hostile_melee")
						act.start_position = path[-1]
						act.utility = 50
					else:
						var step_index = min(max(0, (number_of_moves) * creature.get_stat("max_mp")), path.size() - 1)
						act.start_position = path[step_index]
						act.utility = 0

				sequence[i] = act

func combinatorial(sequences, current, indice: int, changes_needed: int):
	"returns an exhaustive number of sequences that incorporate 'move' and 'empty' activities as 0s and 1s"
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
