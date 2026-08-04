extends Node
class_name CrisisAI

var wm = null

var creature: Creature = null
var tactical_report: TacticalReport = null

@onready var htn_network: HTNetwork = load("res://resources/AI/TaskLists/default_HTN.tres")

func realize_turn():
	Global.simulation_lock = true
	
	while true:
		var sequence: Array[PlannedAct] = plan_turn()
		if await execute(sequence):
			break

	turn_completed()
	Global.simulation_lock = false
	SignalBus.turn_ends.emit()


func plan_turn() -> Array[PlannedAct]:
	SignalBus.clear_path_preview.emit()
	var existing_method: HTNMethod = tactical_report.crisis.turn.chosen_method
	var sequence: Array[PlannedAct] = []

	ReportHelper.produce_report(tactical_report, creature)
	if not tactical_report.crisis.closest_enemy:
		SignalBus.turn_ends.emit()
		return []

	if existing_method:
		tactical_report.crisis.turn.chosen_method = null
		sequence = existing_method.generate(tactical_report)

	if sequence.is_empty():
		sequence = htn_network.apply_strategy(tactical_report)

	return sequence


func execute(sequence: Array[PlannedAct]) -> bool:
	for act in sequence:
		if creature.interrupted:
			creature.interrupted = false
			return false

		act.activity_variant.execute(creature, act.targets)
		ReportHelper.update_report_on_activity(act, tactical_report)

		await get_tree().create_timer(0.2).timeout

		if Global.pending_crisis_operation_count > 0:
			await SignalBus.operation_finished

	return true


func crisis_entered() -> void:
	tactical_report.crisis = CrisisReport.new()
	tactical_report.crisis.turn = TurnReport.new()


func turn_completed() -> void:
	tactical_report.crisis.turn.chosen_method = null
	tactical_report.crisis.turn_counter += 1
	#SignalBus.message.emit("AI turn: %d" % [tactical_report.crisis.turn_counter])
	#tactical_report.crisis.preparation_utility -= 10

func _ready() -> void:
	tactical_report = TacticalReport.new()
	tactical_report.crisis = CrisisReport.new()
	tactical_report.crisis.turn = TurnReport.new()
	creature = $"../.."
	wm = Global.world_manager
