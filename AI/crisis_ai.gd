extends Node

class_name CrisisAI

var wm = null

var creature: Creature = null
var situation: SituationModule = null
var movement: MovementModule = null
var evaluator: EvaluatorModule = null

var activities = []

func plan_turn():
	activities = get_all_activities()
	var sequences = []
	var report = situation.produce_report()
	movement.movement_planner(sequences, report)
	evaluator.activity_selector(sequences, report)
	#execute(best_sequence)

func get_all_activities():
#	maybe add weapon_attack manually & directly at the start of the array
	for activity in creature.data.activities:
		activities.append(activity)
	for spell in creature.data.spells_ready:
		for activity in spell.activities:
			activities.append(activity)
	return activities

#func score_sequence(sequence):
	#var total_score = 0
	#pass

func setup(world_manager, owner_creature: Creature):
	wm = world_manager
	creature = owner_creature

func _ready() -> void:
	situation = $SituationModule
	movement = $MovementModule
	evaluator = $EvaluatorModule
	
	for child in get_children():
		if child.has_method("setup"):
			child.setup(wm, creature, self)
