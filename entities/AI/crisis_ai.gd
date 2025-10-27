extends Node

class_name CrisisAI

var creature: Creature = null
var activities = []
var sequences = []
var best_sequence = null
var best_score: int = 0

func plan_turn():
	activities = get_all_activities()
	sequences = generate_all_action_sequences()

	best_sequence = null
	best_score = 0

	for sequence in sequences:
		var score = score_sequence(sequence)
		if score > best_score:
			best_score = score
			best_sequence = sequence

	return best_sequence

func get_all_activities():
#	maybe add weapon_attack manually & directly at the start of the array
	for activity in creature.data.activities:
		activities.append(activity)
	for spell in creature.data.spells_ready:
		for activity in spell.activities:
			activities.append(activity)
	return activities

func generate_all_action_sequences():
	var avalaible_ap = creature.data.current_ap
	
	for activity in activities:
		var sequence = [activity]
		if (avalaible_ap - activity.AP_cost) == 0:
			sequences.append(sequence)
		elif (avalaible_ap - activity.AP_cost) > 0:
			generate_sequences(sequence, avalaible_ap)
		else:
			continue

func generate_sequences(sequence, avalaible_ap):
	for activity in activities:
		var remaining_ap = avalaible_ap - activity.AP_cost
		if remaining_ap >= 0:
			var new_sequence = sequence.duplicate()
			new_sequence.append(activity)
			if remaining_ap == 0:
				sequences.append(new_sequence)
			else:
				generate_sequences(new_sequence, remaining_ap)

func score_sequence(sequence):
	var total_score = 0
	pass

func _ready() -> void:
	creature = get_parent().get_parent()
