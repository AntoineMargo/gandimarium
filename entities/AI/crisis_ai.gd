extends Node

class_name CrisisAI

var creature: Creature = null
var activities = []
var all_sequences = []
var best_sequence = null
var best_score: int = 0

func plan_turn(creature):
	activities = get_all_activities(creature)
	all_sequences = generate_all_action_sequences(activities, creature)

	best_sequence = null
	best_score = 0

	for sequence in all_sequences:
		var score = score_sequence(sequence, creature)
		if score > best_score:
			best_score = score
			best_sequence = sequence

	return best_sequence

func get_all_activities(creature):
	pass

func generate_all_action_sequences(activities, creature):
	pass

func score_sequence(sequence, creature):
	pass

func _ready() -> void:
	creature = get_parent().get_parent()
