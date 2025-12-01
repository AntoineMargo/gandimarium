extends Node

class_name CrisisAI

var wm = null

var creature: Creature = null
var situation: SituationModule = null
var movement: MovementModule = null
var evaluator: EvaluatorModule = null
var executor: ExecutorModule = null

var activities = []

func plan_turn():
	var entries = get_all_activity_entries()
	var sequences = []
	var report = situation.produce_report(entries)
	movement.movement_planner(sequences, report)
	evaluator.activity_selector(sequences, report, entries)
	var activities = evaluator.sequence_assessor(sequences, report, entries)
	executor.execute(activities)

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
		entry.activity = creature.data.get_modified_activity(activity)
		entry.hint = entry.activity.ai_hint
		entries.append(entry)
		
func add_spell_entries(entries):
	for spell in creature.data.spells_ready:
		for activity in spell.activities:
			var entry = ActivityEntry.new()
			entry.activity = creature.data.get_modified_activity(activity)
			entry.hint = entry.activity.ai_hint
			entries.append(entry)

func add_weapon_entries(entries):
	var weapons = creature.data.get_active_weapons()

	var main_attack = ActivityEntry.new()
	if weapons[0].shoot:
		main_attack.activity = creature.data.get_modified_activity(weapons[0].shoot)
	else:
		main_attack.activity = creature.data.get_modified_activity(weapons[0].strike)
	main_attack.hint = main_attack.activity.ai_hint
	entries.append(main_attack)

	var offhand_attack = ActivityEntry.new()
	if weapons[1].shoot:
		offhand_attack.activity = creature.data.get_modified_activity(weapons[1].shoot)
	else:
		offhand_attack.activity = creature.data.get_modified_activity(weapons[1].strike)
	offhand_attack.hint = offhand_attack.activity.ai_hint
	entries.append(offhand_attack)

func add_default_entries(entries):
	return entries

func setup(world_manager, owner_creature: Creature):
	wm = world_manager
	creature = owner_creature

func _ready() -> void:
	situation = $SituationModule
	movement = $MovementModule
	evaluator = $EvaluatorModule
	executor = $ExecutorModule
	
	for child in get_children():
		if child.has_method("setup"):
			child.setup(wm, creature, self)
