extends Node
class_name NoiseManager

var wm = null

func check_path_to_noise(origin: Vector3i, goal: Vector3i) -> float:
	if origin.z != goal.z:
		return 999
		
	var noise_map = wm.layers[origin.z]["noise_map"]
	var tile_map = wm.layers[origin.z]["tile_map"]

	var path: PackedVector2Array = noise_map.get_point_path(Vector2i(origin.x, origin.y), Vector2i(goal.x, goal.y))
	if path:
		return calculate_noise_path_2D(path, tile_map)
	return 999

func check_vertical_noise(origin: Vector3i, goal: Vector3i) -> float:
	var path = WorldMath.bresenham_line_3d(origin.x, origin.y, origin.z, goal.x, goal.y, goal.z)
	var cost = calculate_noise_path_3D(path)
	return cost

func calculate_noise_path_3D(path) -> float:
	if path.size() <= 1:
		return 0.0
	
	var total_cost = 0.0

	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]

		var delta = curr - prev
		
		var prev_map = wm.layers[prev.z]["tile_map"]
		var curr_map = wm.layers[curr.z]["tile_map"]
		
		var prev_tile_data = prev_map.get_cell_tile_data(Vector2i(prev.x, prev.y))
		var curr_tile_data = curr_map.get_cell_tile_data(Vector2i(curr.x, curr.y))

		var step_cost: float = 1.0

		if delta.z == 1:
			if curr_tile_data:
				if curr_tile_data.get_custom_data("floor") == true:
					step_cost += 10
		elif delta.z == -1:
			if prev_tile_data:
				if prev_tile_data.get_custom_data("floor") == true:
					step_cost += 10

		if curr_tile_data:
			if curr_tile_data.get_custom_data("cover") == Enums.Cover.FULL:
				step_cost += 10

		var is_diagonal = abs(delta.x) + abs(delta.y) == 2
		if is_diagonal:
			step_cost *= 1.5

		total_cost += step_cost
	
	return total_cost

func calculate_noise_path_2D(path, tile_map) -> float:
	if path.size() <= 1:
		return 0.0
	
	var total_cost = 0.0

	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]

		var prev_tile = Vector2i(prev.x, prev.y)
		var curr_tile = Vector2i(curr.x, curr.y)
		var delta = curr_tile - prev_tile

		var proper_curr_tile = wm.pixels_to_tile(curr_tile, 0)
		var tile_data = tile_map.get_cell_tile_data(Vector2i(proper_curr_tile.x, proper_curr_tile.y))

		var step_cost = 1.0
		if tile_data:
			if tile_data.get_custom_data("cover") == Enums.Cover.FULL:
				step_cost = 10

		var is_diagonal = abs(delta.x) == 1 and abs(delta.y) == 1
		if is_diagonal:
			step_cost *= 1.5

		total_cost += step_cost
	
	return total_cost

func get_sound_vector(origin: Vector3i, sound: Vector3i) -> Vector3i:
	if origin == sound:
		return Vector3i.ZERO
	
	var dir: Vector3i = sound - origin
	return Vector3i(sign(dir.x), sign(dir.y), sign(dir.z))






















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
