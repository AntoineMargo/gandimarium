extends Node
class_name CrisisAI

var wm = null

var creature: Creature = null
var tactical_report: TacticalReport = null

@onready var htn_network: HTNetwork = load("res://resources/AI/TaskLists/default_HTN.tres")

func plan_turn():
	if tactical_report.needs_update:
		ReportHelper.produce_report(tactical_report, creature)
	if not tactical_report.crisis.closest_enemy:
		SignalBus.turn_ends.emit()
		return
	var sequence: Array[PlannedAct] =  htn_network.apply_strategy(tactical_report)
	execute(sequence)

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
	tactical_report = TacticalReport.new()
	tactical_report.crisis = CrisisReport.new()
	tactical_report.crisis.turn = TurnReport.new()
	creature = $"../.."
	wm = Global.world_manager
