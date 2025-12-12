extends Node

class_name CrisisAI

var wm = null

var creature: Creature = null

var situation: SituationModule = null
var movement: MovementModule = null
var evaluator: EvaluatorModule = null
var executor: ExecutorModule = null

var planned_sequence = [] # final chosen planned sequence of activities

func plan_turn():
	var entries = get_all_activity_entries() # series of Activity / AiHint tuples
	var sequences = [] # series of PlannedAct arrays based on available AP
	var report = situation.produce_report(entries)
	if not report["closest_enemy"]:
		return
	
	movement.movement_planner(sequences, report)
	evaluator.activity_selector(sequences, report, entries)
	planned_sequence = evaluator.sequence_assessor(sequences, report, entries)
	executor.execute(planned_sequence)

func get_all_activity_entries():
	var entries = []

	add_weapon_entries(entries)
	add_default_entries(entries)
	add_activity_entries(entries)
	add_spell_entries(entries)

	return entries

func add_activity_entries(entries):
	for activity in creature.data.activities:
		var entry = ActivityEntry.new()
		entry.activity = creature.get_modified_activity(activity)
		entry.hint = entry.activity.ai_hint
		entries.append(entry)
		
func add_spell_entries(entries):
	for spell in creature.data.spells_ready:
		for activity in spell.activities:
			var entry = ActivityEntry.new()
			entry.activity = creature.get_modified_activity(activity)
			entry.hint = entry.activity.ai_hint
			entries.append(entry)

func add_weapon_entries(entries):
	var weapons = creature.get_active_weapons()
	if weapons[0]:
		var main_attack = ActivityEntry.new()
		if weapons[0].shoot:
			main_attack.activity = creature.get_modified_activity(weapons[0].shoot)
		else:
			main_attack.activity = creature.get_modified_activity(weapons[0].strike)
		main_attack.activity.weapon = weapons[0]
		main_attack.hint = main_attack.activity.ai_hint
		entries.append(main_attack)

	if weapons[1]:
		var offhand_attack = ActivityEntry.new()
		if weapons[1].name == weapons[0].name:
			return
		if weapons[1].shoot:
			offhand_attack.activity = creature.get_modified_activity(weapons[1].shoot)
		else:
			offhand_attack.activity = creature.get_modified_activity(weapons[1].strike)
		offhand_attack.activity.weapon = weapons[1]
		offhand_attack.hint = offhand_attack.activity.ai_hint
		entries.append(offhand_attack)

func add_default_entries(entries):
	return entries

func setup(world_manager, owner_creature: Creature):
	wm = world_manager
	creature = owner_creature
	print("CrisisAI")
	print("	creature: ", creature)
	print("	wm: ", wm)

func _ready() -> void:
	situation = $SituationModule
	movement = $MovementModule
	evaluator = $EvaluatorModule
	executor = $ExecutorModule
	creature = $"../.."
