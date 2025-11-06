extends Node

var wm = Global.world_manager

func produce_report(creature: Creature) -> Dictionary:
	var report = {}

	var closest_enemy = find_closest_enemy(creature)
	var strongest_enemy = find_strongest_enemy(creature)
	var frailest_enemy = find_frailest_enemy(creature)

	report["closest_enemy"] = closest_enemy
	report["strongest_enemy"] = strongest_enemy
	report["frailest_enemy"] = frailest_enemy
	
	report["enemy_positions"] = {}
	for enemy in creature.data.hostile:
		var data = enemy.data
		report["enemy_positions"][enemy] = Vector3i(data.tile_x, data.tile_y, data.map_layer_id)

	return report

func find_closest_enemy(creature) -> Creature:
	var closest_enemy: Creature = null
	var best_cost: float = INF
	for enemy in creature.data.hostile:
		var path = wm.path_to_target_adjacency(creature, enemy)
		if path:
			var cost = wm.calculate_path_cost_3D(path)
			if best_cost > cost:
				best_cost = cost
				closest_enemy = enemy
	return closest_enemy

func find_strongest_enemy(creature) -> Creature:
	var strongest_enemy: Creature = null
	var lowest_level: int = 100
	var level_difference: int = 0

	for enemy in creature.data.hostile:
		if strongest_enemy == null or enemy.data.level > strongest_enemy.data.perceive_level():
			strongest_enemy = enemy
		if enemy.data.level < lowest_level:
			lowest_level = enemy.data.perceive_level()
	level_difference = strongest_enemy.data.perceive_level() - lowest_level
	return strongest_enemy if level_difference > 1 else null

func find_frailest_enemy(creature) -> Creature:
	var frailest_enemy: Creature = null

	for enemy in creature.data.hostile:
		if frailest_enemy == null or enemy.data.perceive_health() < frailest_enemy.data.perceive_health():
			frailest_enemy = enemy
	return frailest_enemy
