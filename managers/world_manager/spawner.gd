extends Node

class_name Spawner

var wm = null

func spawn_character_player():
	if not guardian():
		return

	var my_char = CreatureData.new()
	my_char.name = "Andimar"
	my_char.level = 12
	my_char.acuity = 7
	my_char.brawn = 6
	my_char.dexterity = 7
	my_char.will = 6

	my_char.map_id = wm.current_world.id
	my_char.map_layer_id = wm.current_level
	
	my_char.is_player = true
	my_char.crisis_ai_active = false
	
	my_char.initialise()
	
	var longsword := load("res://items/weapons/wpn_longsword.tres")
	#my_char.inventory.append(longsword)
	var longspear := load("res://items/weapons/wpn_longspear.tres")
	my_char.inventory.append(longspear)
	var med_shield := load("res://items/weapons/wpn_medium_shield.tres")
	my_char.inventory.append(med_shield)
	var light_armour := load("res://items/armours/ar_light.tres")
	my_char.inventory.append(light_armour)
	var heavy_armour := load("res://items/armours/ar_heavy.tres")
	my_char.inventory.append(heavy_armour)
	var light_shield := load("res://items/weapons/wpn_light_shield.tres")
	my_char.inventory.append(light_shield)
	var medium_shield := load("res://items/weapons/wpn_medium_shield.tres")
	#my_char.inventory.append(medium_shield)
	var heavy_shield := load("res://items/weapons/wpn_large_shield.tres")
	my_char.inventory.append(heavy_shield)
	var mace := load("res://items/weapons/wpn_mace.tres")
	my_char.inventory.append(mace)
	var poleaxe := load("res://items/weapons/wpn_poleaxe.tres")
	#my_char.inventory.append(poleaxe)
	var warhammer := load("res://items/weapons/wpn_warhammer.tres")
	my_char.inventory.append(warhammer)
	var partisan := load("res://items/weapons/wpn_partisan.tres")
	my_char.inventory.append(partisan)
	var battleaxe := load("res://items/weapons/wpn_battle_axe.tres")
	my_char.inventory.append(battleaxe)
	var dagger := load("res://items/weapons/wpn_dagger.tres")
	my_char.inventory.append(dagger)
	var falchion := load("res://items/weapons/wpn_falchion.tres")
	my_char.inventory.append(falchion)
	var shortsword := load("res://items/weapons/wpn_shortsword.tres")
	my_char.inventory.append(shortsword)
	var quarterstaff := load("res://items/weapons/wpn_quarterstaff.tres")
	my_char.inventory.append(quarterstaff)
	var greatsword := load("res://items/weapons/wpn_greatsword.tres")
	my_char.inventory.append(greatsword)
	var great_axe := load("res://items/weapons/wpn_great_axe.tres")
	my_char.inventory.append(great_axe)
	var saber := load("res://items/weapons/wpn_saber.tres")
	my_char.inventory.append(saber)
	var bow := load("res://items/weapons/wpn_bow.tres")
	my_char.inventory.append(bow)

	my_char.set1_left_hand = poleaxe
	my_char.set1_right_hand = null

	my_char.set2_left_hand = longsword
	my_char.set2_right_hand = medium_shield

	var move = load("res://activities/activities/move.tres")
	var aura_damage = load("res://activities/activities/aura_damage.tres")
	var firebolt = load("res://activities/activities/firebolt.tres")
	var firebolts = load("res://activities/activities/firebolts.tres")
	my_char.add_activity(move)
	my_char.add_activity(aura_damage)
	my_char.add_activity(firebolt)
	my_char.add_activity(firebolts)

	var firebolt_spell = load("res://abilities/spells/firebolt.tres")
	my_char.add_ready_spell(firebolt_spell)
	
	var degrade_defences_spell = load("res://abilities/spells/degrade_defences.tres")
	my_char.add_ready_spell(degrade_defences_spell)
	
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)

	_spawn_character_helper(my_char)

func spawn_character_enemy():
	if not guardian():
		return
	var my_char = CreatureData.new()
	my_char.name = "Bandit"
	my_char.level = 8
	my_char.acuity = 7
	my_char.brawn = 6
	my_char.dexterity = 7
	my_char.will = 6

	my_char.map_id = wm.current_world.id
	my_char.map_layer_id = wm.current_level
	
	my_char.is_player = false
	my_char.crisis_ai_active = true
	
	my_char.initialise()
	
	var longsword := load("res://items/weapons/wpn_longsword.tres")
	var medium_shield := load("res://items/weapons/wpn_medium_shield.tres")
	
	my_char.set1_left_hand = longsword
	my_char.set1_right_hand = medium_shield
	
	var move = load("res://activities/activities/move.tres")

	my_char.add_activity(move)

	var char_instance = _spawn_character_helper(my_char)
	
	var texture = load("res://art/characters/hooded_char_blue.png")
	char_instance.sprite_node.texture = texture

func guardian():
	if wm.current_world == null:
		print("No current world.")
		return false
	var tile_coords = wm.get_tile_coords()
	var tile_data = wm.current_tile_map_layer.get_cell_tile_data(tile_coords.vec2)
	if not tile_data.get_custom_data("walkable") or wm.layers[wm.current_level]["occupied"].get(tile_coords.vec2, false):
		print("Cannot spawn character on this tile!")
		return false
	return true

func _spawn_character_helper(my_char):
	var char_scene = load("res://entities/creature.tscn")
	var char_instance = char_scene.instantiate()
	char_instance.data = my_char

	var tile_coords = wm.get_tile_coords()
	my_char.tile_x = tile_coords.vec2.x
	my_char.tile_y = tile_coords.vec2.y
	char_instance.position = wm.layers[tile_coords.vec3.z]["tile_map"].map_to_local(tile_coords.vec2)
	wm.current_world.add_child(char_instance)
	wm.current_world.register_creature(char_instance)
	wm.layers[wm.current_level]["occupied"][tile_coords.vec2] = true
	my_char.map_id = "world"
	wm.add_to_tile(char_instance, tile_coords)
	wm.layers[wm.current_level]["path_map"].set_point_solid(tile_coords.vec2, true)
	wm.selection_highlight.update_selection_highlight()
	my_char.make_active_set(1)
	#focus_char = char_instance
	
	for creature in wm.current_world.creatures:
		if creature.data.is_player:
			my_char.hostile.append(creature)
	
	return char_instance

#func _ready():
	#pass
