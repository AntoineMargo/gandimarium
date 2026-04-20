extends Node
class_name SituationModule

var wm: WorldManager = null
var creature: Creature = null

func produce_report(entries) -> Dictionary:
	var report = {}

	var closest_enemy = find_closest_enemy()
	var strongest_enemy = find_strongest_enemy()
	var frailest_enemy = find_frailest_enemy()
	var favored_melee_attack = find_best_melee_attack(entries)
	var favored_ranged_attack = find_best_ranged_attack(entries)

	report["closest_enemy"] = closest_enemy
	report["strongest_enemy"] = strongest_enemy
	report["frailest_enemy"] = frailest_enemy
	report["favored_melee_attack"] = favored_melee_attack
	report["favored_ranged_attack"] = favored_ranged_attack
	
	report["enemy_positions"] = {}
	for id in creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null:
			continue

		var data = enemy.data
		report["enemy_positions"][enemy] = Vector3i(data.tile_x, data.tile_y, data.tile_z)

	return report

func find_best_ranged_attack(entries):
	var favored_ranged_attack: Activity = null
	var highest_brawn_requirement: int = 0
	
	for i in range(2):
		if entries[i].activity.weapon and entries[i].activity.triggers_reaction:
			if entries[i].activity.weapon.brawn_req_2h > highest_brawn_requirement:
				favored_ranged_attack = entries[i].activity
				highest_brawn_requirement = entries[i].activity.weapon.brawn_req_2h
		else:
			break
	return favored_ranged_attack

func find_best_melee_attack(entries):
	print("=== find_best_melee_attack ===")
	var favored_melee_attack: Activity = null
	var highest_brawn_requirement: int = 0
	
	for i in range(2):
		print("activity name: ", entries[i].activity.name)
		if entries[i].activity.weapon and not entries[i].activity.triggers_reaction:
			if entries[i].activity.weapon.brawn_req_2h >= highest_brawn_requirement:
				favored_melee_attack = entries[i].activity
				highest_brawn_requirement = entries[i].activity.weapon.brawn_req_2h
		else:
			break
	return favored_melee_attack

func find_closest_enemy() -> Creature:
	var closest_enemy: Creature = null
	var best_cost: float = INF

	for id in creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null or not enemy.data.state == Enums.State.CONSCIOUS:
			continue

		var path = wm.path_to_target_adjacency(creature, enemy, 1)
		if path:
			var cost = wm.calculate_path_cost_3D_simple(path)
			if best_cost > cost:
				best_cost = cost
				closest_enemy = enemy

	return closest_enemy


func find_strongest_enemy() -> Creature:
	var strongest_enemy: Creature = null
	var lowest_level: int = 100

	for id in creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null or not enemy.data.state == Enums.State.CONSCIOUS:
			continue

		if strongest_enemy == null or enemy.data.level > strongest_enemy.perceive_level():
			strongest_enemy = enemy
		if enemy.data.level < lowest_level:
			lowest_level = enemy.perceive_level()

	return strongest_enemy

func find_frailest_enemy() -> Creature:
	var frailest_enemy: Creature = null

	for id in creature.data.relationships._hostile_ids.keys():
		var enemy = Global.world_manager.get_creature_by_id(id)
		if enemy == null or not enemy.data.state == Enums.State.CONSCIOUS:
			continue

		if frailest_enemy == null or enemy.perceive_health() < frailest_enemy.perceive_health():
			frailest_enemy = enemy
	return frailest_enemy

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
