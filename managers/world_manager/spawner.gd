extends Node

class_name Spawner

var wm = null

func spawn_character_player():
	if not _guardian():
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
	
	my_char.player_controlled = true
	my_char.crisis_ai_active = false
	
	my_char.initialise()
	
	var items = ["wpn_saber", "wpn_longspear", "wpn_great_axe", "ar_light",
	"ar_heavy", "wpn_light_shield", "wpn_bow", "wpn_large_shield",
	"wpn_mace", "wpn_poleaxe", "wpn_warhammer", "wpn_partisan",
	"wpn_battle_axe", "wpn_dagger", "wpn_falchion", "wpn_shortsword",
	"wpn_quarterstaff", "wpn_greatsword"]
	
	var activities = ["move", "aura_damage", "firebolt", "firebolts"]
	
	var abilities = ["firebolt", "degrade_defences"]

	my_char.equip_item("set1_left_hand", Library.get_item("wpn_poleaxe"))
	my_char.equip_item("set1_right_hand", null)
	
	my_char.equip_item("set2_left_hand", Library.get_item("wpn_longsword"))
	my_char.equip_item("set2_right_hand", Library.get_item("wpn_medium_shield"))

	_spawn_character_helper(items, activities, abilities, my_char)
	
func spawn_character_enemy():
	if not _guardian():
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
	
	my_char.crisis_ai_active = true
	
	my_char.initialise()
	
	var items = []
	
	var activities = ["move"]
	
	var abilities = []
	
	my_char.equip_item("set1_left_hand", Library.get_item("wpn_longsword"))
	my_char.equip_item("set1_right_hand", Library.get_item("wpn_medium_shield"))

	var char_instance = _spawn_character_helper(items, activities, abilities, my_char)

	var texture = load("res://art/characters/hooded_char_blue.png")
	char_instance.sprite_node.texture = texture
	
func _guardian():
	if wm.current_world == null:
		print("No current world.")
		return false
	var tile_coords = wm.get_tile_coords()
	var tile_data = wm.current_tile_map_layer.get_cell_tile_data(tile_coords.vec2)
	if not tile_data.get_custom_data("walkable") or wm.layers[wm.current_level]["occupied"].get(tile_coords.vec2, false):
		print("Cannot spawn character on this tile!")
		return false
	return true

func _spawn_character_helper(items, activities, abilities, my_char):
	
	for item_ref in items:
		var item = Library.get_item(item_ref)
		if item:
			my_char.inventory.append(item)
	
	for activity_ref in activities:
		var activity = Library.get_activity(activity_ref)
		if activity:
			my_char.add_activity(activity)
	
	for ability_ref in abilities:
		var ability = Library.get_ability(ability_ref)
		if ability:
			my_char.add_ready_spell(ability)
	
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
	my_char.make_active_set(0)
	#focus_char = char_instance
	
	return char_instance

#func _ready():
	#pass
