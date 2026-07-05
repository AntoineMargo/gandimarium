extends Node
class_name ExecutorModule

var wm: WorldManager = null
var creature: Creature = null

func execute(report: Dictionary):
	var slots: Array[HTNPrimitiveSlot] = report["method"].primitive_slots
	Global.simulation_lock = true
	for slot in slots:
		if slot.AP_cost > creature.get_stat("current_ap"):
			break
		slot.primitive.activity_variant.execute(creature, slot.targets)
		await get_tree().create_timer(0.2).timeout
	Global.simulation_lock = false
	SignalBus.turn_ends.emit()

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
