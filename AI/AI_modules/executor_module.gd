extends Node
class_name ExecutorModule

var wm: WorldManager = null
var creature: Creature = null

func execute(planned_sequence):
	for planned_act in planned_sequence:
		if planned_act.activity.name == "Move":
			creature.data.perform_activity(planned_act.activity)
			print("planned_act.target_position: ", planned_act.target_position)
			wm._interact_move(planned_act.target_position)
		elif planned_act.target_creature:
			creature.data.perform_activity(planned_act.activity, planned_act.target_creature)
		else:
			creature.data.perform_activity(planned_act.activity)

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
