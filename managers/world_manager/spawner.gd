extends Node

class_name Spawner

var wm = null

func _guardian():
	if wm.current_map == null:
		print("No current world.")
		return false
	var tile_coords = wm.get_tile_coords()
	var tile_data = wm.current_tile_map_layer.get_cell_tile_data(tile_coords.vec2)
	if not tile_data.get_custom_data("walkable") or wm.layers[wm.current_layer]["occupied"].get(tile_coords.vec2, false):
		print("Cannot spawn character on this tile!")
		return false
	return true

func add_default_activities(char_data) -> void:
	var move_activity = load("res://resources/activity_containers/move.tres")
	var recuperate_activity = load("res://resources/activity_containers/recuperate.tres")
	
	char_data.activities.append(move_activity)
	char_data.activities.append(recuperate_activity)


func level_up_creature(creature: Creature) -> void:
	if not creature.data.player_controlled:
		creature.start_mutation()
		for i in range(creature.data.applied_level, creature.data.level):
			creature.level_up()
		creature.end_mutation()


func apply_routine(creature: Creature, routine) -> void:
	var char_routine: LocalRoutine = load(routine)
	#char_routine = char_routine.duplicate(true) # Not needed for now
	if creature.ai_controller and creature.ai_controller.localai:
		creature.ai_controller.localai.routine = char_routine


func register_creature(creature: Creature) -> void:
	wm.current_map.register_creature(creature)
	Global.state_manager.register_creature(creature)


## Don't use guardian for scene tile spawners
func spawn_creature_at_coords(data_file: String, coords: Vector3i, map_id: String, routine: String = "", guardian: bool = true) -> Creature:
	if guardian and not _guardian():
		return null

	var char_data: CreatureData = load(data_file)
	char_data = char_data.duplicate(true)

	var char_scene = load("res://entities/creature.tscn")
	var character_node: CreatureNode = char_scene.instantiate()
	
	add_default_activities(char_data)
	
	var character: Creature = Creature.new(char_data)
	character.attach_node(character_node)

	var layer_coords = Vector2i(coords.x, coords.y)
	character.data.tile_x = coords.x
	character.data.tile_y = coords.y
	character.data.tile_z = coords.z
	character.data.map_id = Global.world_manager.get_current_map_id()

	character_node.position = wm.layers[coords.z]["tile_map"].map_to_local(layer_coords)

	Global.game_session.add_child(character_node)

	wm.layers[wm.current_layer]["occupied"][layer_coords] = true
	wm.add_to_tile_contents(character, coords)
	wm.layers[wm.current_layer]["path_map"].set_point_solid(layer_coords, true)
	
	var weapons = character.get_weapons()
	for weapon in weapons:
		if weapon:
			weapon.initialize_attack_modes()

	call_deferred("register_creature", character)

	call_deferred("level_up_creature", character)

	if routine:
		call_deferred("apply_routine", character, routine)

	var current_map_id: String = Global.world_manager.get_current_map_id()
	var current_layer: int = Global.world_manager.get_current_layer()
	character.update_visibility(current_map_id, current_layer)

	return character


func spawn_creature(creature: Creature) -> void:
	var tile_coords = creature.get_coords()
	var layer_coords = Vector2i(tile_coords.x, tile_coords.y)
	#var map_data = Global.map_manager.get_map_data_from_map_id(creature.get_map_id())
	var tile_data = wm.current_tile_map_layer.get_cell_tile_data(layer_coords)
	if not tile_data.get_custom_data("walkable") or wm.layers[tile_coords.z]["occupied"].get(layer_coords, false):
		print("Cannot spawn creature on this tile!")

	var creature_scene = load("res://entities/creature.tscn")
	var creature_node: CreatureNode = creature_scene.instantiate()
	creature.attach_node(creature_node)


	creature_node.position = wm.layers[tile_coords.z]["tile_map"].map_to_local(layer_coords)

	Global.game_session.add_child(creature_node)

	wm.layers[wm.current_layer]["occupied"][layer_coords] = true
	wm.add_to_tile_contents(creature, tile_coords)
	wm.layers[wm.current_layer]["path_map"].set_point_solid(layer_coords, true)

	#creature.initialize_character()
	#wm.current_map.register_creature(creature)
	call_deferred("register_creature", creature)
	
	var weapons = creature.get_weapons()
	for weapon in weapons:
		if weapon:
			weapon.initialize_attack_modes()

	var current_map_id: String = Global.world_manager.get_current_map_id()
	var current_layer: int = Global.world_manager.get_current_layer()
	creature.update_visibility(current_map_id, current_layer)

	#if not char_data.player_controlled:
		#character.start_mutation()
		#for i in range(char_data.applied_level, char_data.level):
			#character.level_up()
		#character.end_mutation()


#func _ready():
	#pass
