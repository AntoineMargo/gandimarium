extends Node
class_name ExecutorModule

var wm = null
var creature: Creature = null
var crisis_ai: CrisisAI = null

func execute(planned_sequence):
	for planned_act in planned_sequence:
		if planned_act.activity.name == "Move":
			creature.data.perform_activity(planned_act.activity)
			wm._interact_move(planned_act.target_position)
		elif planned_act.target_creature:
			creature.data.perform_activity(planned_act.activity, planned_act.target_creature)
		else:
			creature.data.perform_activity(planned_act.activity)

func setup(world_manager, owner_creature: Creature, ai_controller: Node):
	wm = world_manager
	creature = owner_creature
	crisis_ai = ai_controller
