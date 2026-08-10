extends Node
class_name CrisisAI

var wm = null

var creature: Creature = null
var report: TacticalReport = null

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
	var existing_method: HTNMethod = report.crisis.turn.chosen_method
	var sequence: Array[PlannedAct] = []

	ReportHelper.produce_report(report, creature)
	if not report.crisis.closest_enemy:
		SignalBus.turn_ends.emit()
		return []

	#report.crisis.turn = TurnReport.new()
	report.crisis.turn.method_is_valid = false

	if existing_method:
		report.crisis.turn.chosen_method = null
		sequence = existing_method.generate(report)

	if sequence.is_empty():
		sequence = htn_network.apply_strategy(report)

	return sequence


func execute(sequence: Array[PlannedAct]) -> bool:
	for act in sequence:
		if !act.activity_variant:
			continue
		
		if creature.interrupted:
			creature.interrupted = false
			return false

		act.activity_variant.execute(creature, act.targets)
		ReportHelper.update_report_on_activity(act, report)

		await get_tree().create_timer(0.2).timeout

		if Global.pending_crisis_operation_count > 0:
			await SignalBus.operation_finished

	return true


func crisis_entered() -> void:
	report.crisis = CrisisReport.new()
	report.crisis.turn = TurnReport.new()


func turn_completed() -> void:
	report.crisis.turn.chosen_method = null
	report.crisis.turn_counter += 1
	#SignalBus.message.emit("AI turn: %d" % [report.crisis.turn_counter])
	#report.crisis.preparation_utility -= 10

func _ready() -> void:
	#report = TacticalReport.new()
	creature = $"../.."
	wm = Global.world_manager
