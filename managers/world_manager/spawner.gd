extends Node

class_name Spawner

var wm = null

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

func spawn_character(data_file: String, coords: Vector3i, routine: String = "", guardian: bool = true):
	# Don't use guardian for scene tile spawners
	if guardian and not _guardian():
		return null

	var char_data: CreatureData = load(data_file)
	char_data = char_data.duplicate(true)

	var char_scene = load("res://entities/creature.tscn")
	var character = char_scene.instantiate()
	character.data = char_data

	var layer_coords = Vector2i(coords.x, coords.y)
	character.data.tile_x = coords.x
	character.data.tile_y = coords.y
	character.data.tile_z = coords.z
	character.data.map_id = "world"

	character.position = wm.layers[coords.z]["tile_map"].map_to_local(layer_coords)

	wm.current_world.add_child(character)

	wm.layers[wm.current_level]["occupied"][layer_coords] = true
	wm.add_to_tile(character, coords)
	wm.layers[wm.current_level]["path_map"].set_point_solid(layer_coords, true)

	#var conditions = character.data.conditions
	#for condition in conditions:
		#if not is_instance_valid(condition):
			#print("Invalid entry detected")

	character.initialise()
	wm.current_world.register_creature(character)
	character.apply_conditions_from_equipment()
	var weapons = character.get_weapons()
	for weapon in weapons:
		if weapon:
			weapon.initialize_attack_modes()

	if routine:
		var char_routine: LocalRoutine = load(routine)
		#char_routine = char_routine.duplicate(true) # Not needed for now
		character.ai_controller.localai.routine = char_routine

	return character

#func _ready():
	#pass
