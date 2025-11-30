extends Node

class_name CrisisAI

var wm = null

var creature: Creature = null
var situation: SituationModule = null
var movement: MovementModule = null
var evaluator: EvaluatorModule = null

var activities = []

func plan_turn():
	var entries = get_all_activity_entries()
	var sequences = []
	var report = situation.produce_report()
	movement.movement_planner(sequences, report)
	evaluator.activity_selector(sequences, report, entries)
	#execute(best_sequence)

func get_all_activity_entries():
	var entries = []

	add_weapon_entries(entries)
	add_default_entries(entries)

	for activity in creature.data.activities:
		var entry = ActivityEntry.new()
		entry.activity = creature.data.get_modified_activity(activity)
		entry.hint = entry.activity.ai_hint
		entries.append(entry)
		
	for spell in creature.data.spells_ready:
		for activity in spell.activities:
			var entry = ActivityEntry.new()
			entry.activity = creature.data.get_modified_activity(activity)
			entry.hint = entry.activity.ai_hint
			entries.append(entry)

	return entries

func add_weapon_entries(entries):
	var weapons = creature.data.get_active_weapons()

	var main_attack = ActivityEntry.new()
	main_attack.activity = creature.data.get_modified_activity(weapons[0].attack)
	main_attack.hint = main_attack.activity.ai_hint
	main_attack.hint.reach = main_attack.activity.weapon.strike_reach
	main_attack.hint.damage = main_attack.activity.weapon.dice_number * main_attack.activity.weapon.damage_die
	entries.append(main_attack)

	var offhand_attack = ActivityEntry.new()
	offhand_attack.activity = creature.data.get_modified_activity(weapons[1].attack)
	offhand_attack.hint = offhand_attack.activity.ai_hint
	offhand_attack.hint.reach = offhand_attack.activity.weapon.strike_reach
	offhand_attack.hint.damage = offhand_attack.activity.weapon.dice_number * offhand_attack.activity.weapon.damage_die
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
	
	for child in get_children():
		if child.has_method("setup"):
			child.setup(wm, creature, self)
