extends Node
class_name SituationModule

var wm: WorldManager = null
var creature: Creature = null

func produce_report(entries) -> Dictionary:
	var report = {}

	var closest_enemy = find_closest_enemy()
	var strongest_enemy = find_strongest_enemy()
	var frailest_enemy = find_frailest_enemy()
	var favored_melee_weapon = find_best_melee_weapon(entries)
	var favored_ranged_weapon = find_best_ranged_weapon(entries)

	report["closest_enemy"] = closest_enemy
	report["strongest_enemy"] = strongest_enemy
	report["frailest_enemy"] = frailest_enemy
	report["favored_melee_weapon"] = favored_melee_weapon
	report["favored_ranged_weapon"] = favored_ranged_weapon
	
	report["enemy_positions"] = {}
	for enemy in creature.data.relationships.hostile:
		var data = enemy.data
		report["enemy_positions"][enemy] = Vector3i(data.tile_x, data.tile_y, data.map_layer_id)

	return report

func find_best_ranged_weapon(entries):
	var favored_ranged_weapon: Weapon = null
	var highest_brawn_requirement: int = 0
	
	for i in range(2):
		if entries[i].activity is WeaponShoot:
			if entries[i].activity.source.brawn_req_2h > highest_brawn_requirement:
				favored_ranged_weapon = entries[i].activity.source
				highest_brawn_requirement = entries[i].activity.source.brawn_req_2h
		else:
			break
	return favored_ranged_weapon

func find_best_melee_weapon(entries):
	var favored_melee_weapon: Weapon = null
	var highest_brawn_requirement: int = 0
	
	for i in range(2):
		if entries[i].activity is WeaponStrike:
			if entries[i].activity.source.brawn_req_2h > highest_brawn_requirement:
				favored_melee_weapon = entries[i].activity.source
				highest_brawn_requirement = entries[i].activity.source.brawn_req_2h
		else:
			break
	return favored_melee_weapon

func find_closest_enemy() -> Creature:
	var closest_enemy: Creature = null
	var best_cost: float = INF
	for enemy in creature.data.relationships.hostile:
		var path = wm.path_to_target_adjacency(creature, enemy, 1)
		if path:
			var cost = wm.calculate_path_cost_3D(path)
			if best_cost > cost:
				best_cost = cost
				closest_enemy = enemy
	return closest_enemy

func find_strongest_enemy() -> Creature:
	var strongest_enemy: Creature = null
	var lowest_level: int = 100
	var level_difference: int = 0

	for enemy in creature.data.relationships.hostile:
		if strongest_enemy == null or enemy.data.level > strongest_enemy.data.perceive_level():
			strongest_enemy = enemy
		if enemy.data.level < lowest_level:
			lowest_level = enemy.data.perceive_level()
	level_difference = strongest_enemy.data.perceive_level() - lowest_level
	return strongest_enemy if level_difference > 1 else null

func find_frailest_enemy() -> Creature:
	var frailest_enemy: Creature = null

	for enemy in creature.data.relationships.hostile:
		if frailest_enemy == null or enemy.data.perceive_health() < frailest_enemy.data.perceive_health():
			frailest_enemy = enemy
	return frailest_enemy

func _ready() -> void:
	creature = $"../../.."
	await get_tree().process_frame
	wm = Global.world_manager
