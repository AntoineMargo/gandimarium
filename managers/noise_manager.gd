extends Node
class_name NoiseManager

const DIRS = [
	Vector3i(-1,0,0),
	Vector3i(1,0,0),
	Vector3i(0,-1,0),
	Vector3i(0,1,0),
	Vector3i(0,0,-1),
	Vector3i(0,0,1)
]

var sound_map = null
var buckets = null

var wm = null

func setup_noise_manager() -> void:
	create_sound_map()
	create_buckets()

func create_sound_map() -> void:
	sound_map = {}

	for z in wm.layers.keys():
		sound_map[z] = []

		for x in range(wm.map_width):
			sound_map[z].append([])

			for y in range(wm.map_height):
				sound_map[z][x].append(-1)

func create_buckets() -> void:
	buckets = []
	for i in range(50):
		buckets.append([])

func get_noise_value_at_pos(pos: Vector3i) -> int:
	return sound_map[pos.z][pos.x][pos.y]

func propagate_sound(origin: Vector3i, sound_power: int):
	for z in sound_map:
		for x in range(wm.map_width):
			for y in range(wm.map_height):
				sound_map[z][x][y] = -1

	for b in buckets:
		b.clear()

	sound_power = min(sound_power, buckets.size() - 1)

	sound_map[origin.z][origin.x][origin.y] = sound_power
	buckets[sound_power].append(origin)

	for power in range(sound_power, 0, -1):
		for tile in buckets[power]:
			for dir in DIRS:

				var n = tile + dir

				if !sound_map.has(n.z):
					continue

				if n.x < 0 or n.y < 0:
					continue
				if n.x >= wm.map_width or n.y >= wm.map_height:
					continue

				var cost: int

				if dir.z == 0:
					cost = 1 + get_horizontal_cost(n.x, n.y, n.z)
				else:
					cost = 1 + get_vertical_cost(tile, dir)
					if cost >= 2: # If there's a roof/floor
						cost += 2 # Additional vertical cost

				var new_power = power - cost

				if new_power <= 0:
					continue

				if new_power > sound_map[n.z][n.x][n.y]:
					sound_map[n.z][n.x][n.y] = new_power
					buckets[new_power].append(n)

func get_horizontal_cost(x:int, y:int, z:int) -> int:

	var coords = Vector2i(x, y)
	var tilemap = wm.layers[z]["tile_map"]
	var tile_data = tilemap.get_cell_tile_data(coords)

	if tile_data:
		if tile_data.get_custom_data("cover") != Enums.Cover.FULL:
			return 0

		var mat = tile_data.get_custom_data("mat")

		match mat:
			Enums.Mat.AIR:
				return 0
			Enums.Mat.SOFT_WOOD:
				return 1
			Enums.Mat.HARD_WOOD:
				return 3
			Enums.Mat.BRICK:
				return 5
			Enums.Mat.ROCK:
				return 7

	return 1

func get_vertical_cost(tile: Vector3i, dir: Vector3i) -> int:

	var check_z : int
	var coords = Vector2i(tile.x, tile.y)

	if dir.z < 0:
		check_z = tile.z
	else:
		check_z = tile.z + 1

	if !wm.layers.has(check_z):
		return 100

	var tilemap = wm.layers[check_z]["tile_map"]
	var tile_data = tilemap.get_cell_tile_data(coords)

	if !tile_data:
		return 0

	if !tile_data.get_custom_data("floor"):
		return 0

	var mat = tile_data.get_custom_data("mat")

	match mat:
		Enums.Mat.SOFT_WOOD:
			return 3
		Enums.Mat.HARD_WOOD:
			return 5
		Enums.Mat.BRICK:
			return 7
		Enums.Mat.ROCK:
			return 10

	return 2

func _ready() -> void:
	SignalBus.world_ready.connect(setup_noise_manager)
	wm = Global.world_manager

#const DIRS = [
	#Vector2i.LEFT,
	#Vector2i.RIGHT,
	#Vector2i.UP,
	#Vector2i.DOWN
#]

#func create_sound_map() -> void:
	#sound_map = []
	#for x in range(wm.map_width):
		#sound_map.append([])
		#for y in range(wm.map_height):
			#sound_map[x].append(-1)

#func propagate_sound(origin: Vector2i, sound_power: int):
	#for x in range(wm.map_width):
		#for y in range(wm.map_height):
			#sound_map[x][y] = -1
#
	#for b in buckets:
		#b.clear()
#
	#sound_power = min(sound_power, buckets.size() - 1)
#
	#sound_map[origin.x][origin.y] = sound_power
	#buckets[sound_power].append(origin)
#
	#for power in range(sound_power, 0, -1):
		#for tile in buckets[power]:
			#for dir in DIRS:
#
				#var n = tile + dir
				#if n.x < 0 or n.y < 0 or n.x >= wm.map_width or n.y >= wm.map_height:
					#continue
#
				#var cost = 1 + get_tile_cost(n.x, n.y)
				#var new_power = power - cost
#
				#if new_power <= 0:
					#continue
#
				#if new_power > sound_map[n.x][n.y]:
					#sound_map[n.x][n.y] = new_power
					#buckets[new_power].append(n)

#func get_tile_cost(x:int, y:int) -> int:
	#var tile_coords = Vector2i(x, y)
	#var mat = 0
	#var tile_data = wm.current_tile_map_layer.get_cell_tile_data(tile_coords)
	#if tile_data:
		#mat = tile_data.get_custom_data("mat")
#
	#match mat:
		#Enums.Mat.AIR:
			#return 0
		#Enums.Mat.SOFT_WOOD:
			#return 1
		#Enums.Mat.HARD_WOOD:
			#return 3
		#Enums.Mat.BRICK:
			#return 5
		#Enums.Mat.ROCK:
			#return 7
		#_:
			#return 1
