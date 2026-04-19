extends Node
class_name ExecutorModule

var wm: WorldManager = null
var creature: Creature = null

func execute(planned_sequence):
	print("=== execute ===")
	if !planned_sequence:
		push_warning("No activity could be produced!")
		return
	for planned_act in planned_sequence:
		if planned_act.activity.name == "Move":
			print("MOVE ACTIVITY")
			creature.perform_activity(planned_act.activity)
			print("planned_act.target_position: ", planned_act.target_position)
			wm.interact_move(creature, planned_act.target_position)
		elif planned_act.target_creature:
			print("TARGETED ACTIVITY")
			creature.perform_activity(planned_act.activity, planned_act.target_creature.get_coords())
			#creature.perform_activity(planned_act.activity, planned_act.target_creature)
		else:
			creature.perform_activity(planned_act.activity)
			print("IMMEDIATE ACTIVITY")
		await get_tree().create_timer(0.3).timeout

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
