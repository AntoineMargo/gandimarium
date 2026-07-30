class_name ReportHelper

static func produce_report(report: TacticalReport, creature: Creature):

	if report.needs_update:
		report.creature = creature
		get_all_activity_entries(report)

	# Crisis
	identify_specific_enemies(report)
	#get_enemy_positions(report)
	#report.crisis.closest_ally = find_closest_ally()
	#report.crisis.most_vulnerable_ally = find_weakest_ally()

	# Turn
	setup_turn_information(report)


static func identify_specific_enemies(report: TacticalReport) -> void:
	report.crisis.closest_enemy = find_closest_enemy(report)
	report.crisis.strongest_enemy = find_strongest_enemy(report)
	report.crisis.most_vulnerable_enemy = find_frailest_enemy(report)


static func setup_turn_information(report: TacticalReport):
	report.crisis.turn.starting_position = report.creature.get_coords()
	
	report.crisis.turn.starting_ap = report.creature.get_stat("max_ap")
	report.crisis.turn.starting_pp = report.creature.get_stat("max_pp")
	report.crisis.turn.starting_mp = report.creature.get_stat("max_mp")


static func get_all_activity_entries(report: TacticalReport):
	add_weapon_entries(report)
	add_activity_entries(report)
	add_spell_entries(report)
	#add_default_entries(report)


static func add_weapon_entries(report: TacticalReport):
	var weapons = report.creature.get_weapons()
	var copy: ActivityVariant
	if weapons[0]:
		if weapons[0].throw and weapons[0].throw.activity.reach > 1:
			copy = weapons[0].throw.duplicate(true)
		if weapons[0].shoot:
			copy = weapons[0].shoot.duplicate(true)
		else:
			copy = weapons[0].strike.duplicate(true)
		if copy:
			report.available_activities.append(copy)
		copy.activity.weapon = weapons[0]

	if weapons[1]:
		if weapons[1].throw and weapons[1].throw.activity.reach > 1:
			copy = weapons[1].throw.duplicate(true)
		if weapons[0].shoot:
			copy = weapons[1].shoot.duplicate(true)
		else:
			copy = weapons[1].strike.duplicate(true)
		if copy:
			report.available_activities.append(copy)
		copy.activity.weapon = weapons[1]


static func add_activity_entries(report: TacticalReport):
	for activity_container in report.creature.data.activities:
		for activity_variant in activity_container.activities:
			if activity_variant.ai_hint:
				report.available_activities.append(activity_variant)


static func add_spell_entries(report: TacticalReport):
	for spell_container in report.creature.data.spells_ready:
		for activity_variant in spell_container.activities:
			if activity_variant.activity.ai_hint:
				report.available_activities.append(activity_variant)


static func find_closest_enemy(report: TacticalReport) -> Creature:
	var closest_enemy: Creature = null
	var best_cost: float = INF

	for id in report.creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null or not enemy.data.state == Enums.State.CONSCIOUS:
			continue

		var path = Global.world_manager.path_to_target_adjacency(report.creature, enemy, 1)
		if path:
			var cost = Global.world_manager.calculate_path_cost_3D_simple(path)
			if best_cost > cost:
				best_cost = cost
				closest_enemy = enemy

	return closest_enemy


static func find_strongest_enemy(report: TacticalReport) -> Creature:
	var strongest_enemy: Creature = null
	var lowest_level: int = 100

	for id in report.creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null or not enemy.data.state == Enums.State.CONSCIOUS:
			continue

		if strongest_enemy == null or enemy.data.level > strongest_enemy.perceive_level():
			strongest_enemy = enemy
		if enemy.data.level < lowest_level:
			lowest_level = enemy.perceive_level()

	return strongest_enemy


static func find_frailest_enemy(report: TacticalReport) -> Creature:
	var frailest_enemy: Creature = null

	for id in report.creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null or not enemy.data.state == Enums.State.CONSCIOUS:
			continue

		if frailest_enemy == null or enemy.perceive_health() < frailest_enemy.perceive_health():
			frailest_enemy = enemy
	return frailest_enemy

#static func get_preparation_value(wanted_acts: Array[WantedAct]) -> int:
	#var preparation_value: int = 0
	#
	#for wanted_act in wanted_acts:
		#var wanted_tags = wanted_act.wanted_tags
#
		#for wanted_tag in wanted_tags:
			#match wanted_tag.tag: 
				#Enums.ActivityTag.BUFF, Enums.ActivityTag.SUMMON, Enums.ActivityTag.SHAPE:
					#preparation_value += wanted_tag.value
#
	#return preparation_value


#static func add_default_entries(report: TacticalReport):
	#return report


#static func get_enemy_positions(report: TacticalReport) -> void:
	#report.crisis.enemy_positions = {}
	#for id in report.creature.data.relationships._hostile_ids.keys():
		#var enemy = Global.world_manager.get_creature_by_id(id)
		#if enemy == null:
			#continue
#
		#var data = enemy.data
		#report.crisis.enemy_positions[enemy] = Vector3i(data.tile_x, data.tile_y, data.tile_z)


#static func find_best_ranged_attack(report: TacticalReport) -> ActivityVariant:
	#var favored_ranged_attack: ActivityVariant = null
	#var highest_brawn_requirement: int = 0
#
	#for entry in report.available_activities:
		#if entry.activity.weapon and entry.activity.triggers_reaction:
			#if entry.activity.weapon.brawn_req_2h > highest_brawn_requirement:
				#favored_ranged_attack = entry
				#highest_brawn_requirement = entry.activity.weapon.brawn_req_2h
		#else:
			#break
	#return favored_ranged_attack
#
#
#static func find_best_melee_attack(report: TacticalReport) -> ActivityVariant:
	#var favored_melee_attack: ActivityVariant = null
	#var highest_brawn_requirement: int = 0
#
	#for entry in report.available_activities:
		#if entry.activity.weapon and not entry.activity.triggers_reaction:
			#if entry.activity.weapon.brawn_req_2h >= highest_brawn_requirement:
				#favored_melee_attack = entry
				#highest_brawn_requirement = entry.activity.weapon.brawn_req_2h
		#else:
			#break
	#return favored_melee_attack
