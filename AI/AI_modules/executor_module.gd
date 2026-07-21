extends Node
class_name ExecutorModule

var wm: WorldManager = null
var creature: Creature = null

func execute(sequence: Array[PlannedAct]):
	Global.simulation_lock = true
	for act in sequence:
		if creature.interrupted:
			creature.interrupted = false
			creature.ai_controller.crisisai.plan_turn() 
			return
		act.activity_variant.execute(creature, act.targets)
		await get_tree().create_timer(0.2).timeout
		if Global.pending_crisis_operation_count > 0:
			await SignalBus.operation_finished
	Global.simulation_lock = false
	SignalBus.turn_ends.emit()

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
