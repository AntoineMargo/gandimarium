extends Node
class_name ExecutorModule

var wm: WorldManager = null
var creature: Creature = null

func execute(planned_sequence):
	print("=== execute ===")
	for planned_act in planned_sequence:
		if planned_act.activity.name == "Move":
			print("MOVE ACTIVITY")
			creature.data.perform_activity(planned_act.activity)
			print("planned_act.target_position: ", planned_act.target_position)
			var goal = wm.turn_3D_coords_into_vector_array(planned_act.target_position)
			wm._interact_move(goal)
		elif planned_act.target_creature:
			print("TARGETED ACTIVITY")
			creature.data.perform_activity(planned_act.activity, planned_act.target_creature)
		else:
			creature.data.perform_activity(planned_act.activity)
			print("IMMEDIATE ACTIVITY")

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
