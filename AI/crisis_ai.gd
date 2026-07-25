extends Node
class_name CrisisAI

var wm = null

var creature: Creature = null

var situation: SituationModule = null
var htn: HTNModule = null
var executor: ExecutorModule = null

@onready var htn_network: HTNetwork = load("res://resources/AI/TaskLists/default_HTN.tres")

func plan_turn():
	var entries: Array[ActivityVariant] = get_all_activity_entries() # series of Activity / AiHint tuples
	var report = situation.produce_report(entries)
	if not report["closest_enemy"]:
		SignalBus.turn_ends.emit()
		return
	var sequence: Array[PlannedAct] =  htn_network.apply_strategy(report)
	executor.execute(sequence)

func get_all_activity_entries():
	var entries: Array[ActivityVariant] = []

	add_weapon_entries(entries)
	add_default_entries(entries)
	add_activity_entries(entries)
	add_spell_entries(entries)

	return entries

func add_activity_entries(entries):
	for activity_container in creature.data.activities:
		for activity_variant in activity_container.activities:
			if activity_variant.ai_hint:
				entries.append(activity_variant)
		
func add_spell_entries(entries):
	for spell_container in creature.data.spells_ready:
		for activity_variant in spell_container.activities:
			if activity_variant.activity.ai_hint:
				entries.append(activity_variant)

func add_weapon_entries(entries):
	var weapons = creature.get_weapons()
	var copy: ActivityVariant
	if weapons[0]:
		if weapons[0].throw and weapons[0].throw.activity.reach > 1:
			copy = weapons[0].throw.duplicate(true)
		if weapons[0].shoot:
			copy = weapons[0].shoot.duplicate(true)
		else:
			copy = weapons[0].strike.duplicate(true)
		if copy:
			entries.append(copy)
		copy.activity.weapon = weapons[0]
		print("weapon_activity_added")

	if weapons[1]:
		if weapons[1].throw and weapons[1].throw.activity.reach > 1:
			copy = weapons[1].throw.duplicate(true)
		if weapons[0].shoot:
			copy = weapons[1].shoot.duplicate(true)
		else:
			copy = weapons[1].strike.duplicate(true)
		if copy:
			entries.append(copy)
		copy.activity.weapon = weapons[1]
		print("weapon_activity_added")

func add_default_entries(entries):
	return entries

func _ready() -> void:
	situation = $SituationModule
	htn = $HTNModule
	executor = $ExecutorModule
	creature = $"../.."
	wm = Global.world_manager

#var planned_sequence = [] # final chosen planned sequence of activities

#func plan_turn():
	#var entries = get_all_activity_entries() # series of Activity / AiHint tuples
	#var sequences = [] # series of PlannedAct arrays based on available AP
	#var report = situation.produce_report(entries)
	#print("report produced")
	#if not report["closest_enemy"]:
		#return
	#
	#movement.movement_planner(sequences, report)
	#print("movement planned")
	#evaluator.activity_selector(sequences, report, entries)
	#print("activities selected")
	#planned_sequence = evaluator.sequence_assessor(sequences, report, entries)
	#print("precise sequence planned")
	#executor.execute(planned_sequence)
	#print("turn executed")
