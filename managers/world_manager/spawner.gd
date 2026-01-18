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

func spawn_character(data_file):
	if not _guardian():
		return null

	var char_data: CreatureData = load(data_file)
	char_data = char_data.duplicate(true)

	var char_scene = load("res://entities/creature.tscn")
	var character = char_scene.instantiate()
	character.data = char_data

	var tile_coords = wm.get_tile_coords()
	character.data.tile_x = tile_coords.vec3.x
	character.data.tile_y = tile_coords.vec3.y
	character.data.tile_z = tile_coords.vec3.z
	character.data.map_id = "world"

	character.position = wm.layers[tile_coords.vec3.z]["tile_map"].map_to_local(tile_coords.vec2)

	wm.current_world.add_child(character)

	wm.layers[wm.current_level]["occupied"][tile_coords.vec2] = true
	wm.add_to_tile(character, tile_coords)
	wm.layers[wm.current_level]["path_map"].set_point_solid(tile_coords.vec2, true)

	character.initialise()
	wm.current_world.register_creature(character)
	character.make_active_set(0)

	return character

#func _ready():
	#pass
