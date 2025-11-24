class_name WorldMath

static func shape_burst(target_entities, user, range):
	for creature in Global.world_manager.current_world.creatures:
		var distance_ok = is_in_range(user, creature, range)
		var visible = has_line_of_sight(user, creature)
		if distance_ok and visible:
			target_entities.append(creature)

static func is_in_range(user: Node, target: Node, range: int) -> bool:
	var user_coords = Vector2i(user.data.tile_x, user.data.tile_y)
	var target_coords = Vector2i(target.data.tile_x, target.data.tile_y)

	var dx = abs(user_coords.x - target_coords.x)
	var dy = abs(user_coords.y - target_coords.y)
	
	var result = floor(sqrt(dx * dx + dy * dy))
	return result <= range
	
static func has_line_of_sight(origin_char, target_char):
	var vm = Global.world_manager
	var origin = vm.get_char_coords(origin_char)
	var target = vm.get_char_coords(target_char)
	return line_of_sight_exists(origin.vec3.x, origin.vec3.y, origin.vec3.z, target.vec3.x, target.vec3.y, target.vec3.z)

static func line_of_sight_exists(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int) -> bool:
	var points = bresenham_line_3d(x1, y1, z1, x2, y2, z2)
	for i in range(1, points.size() - 1): # Skip endpoints
		var current = points[i]
		var previous = points[i - 1]

		var x = current.x
		var y = current.y
		var z = current.z
		var prev_z = previous.z

		var tile = get_tile_data(x, y, z)
		var tile_prev = get_tile_data(x, y, prev_z)

		if z != prev_z:
			# We're moving vertically — check if the space we're moving from is open
			if tile_prev == null or tile_prev.get_custom_data("floor") == true:
				return false
		else:
			# Horizontal — check passability
			if tile == null or tile.get_custom_data("passable") == false:
				return false

	return true

static func get_tile_data(x: int, y: int, z: int):
	var vm = Global.world_manager
	var layer = vm.layers.get(z)
	if not layer:
		return null
	var tile_map: TileMapLayer = layer["tile_map"]
	return tile_map.get_cell_tile_data(Vector2i(x, y))

static func bresenham_line_3d(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int) -> Array:
	var points := []

	var dx = abs(x2 - x1)
	var dy = abs(y2 - y1)
	var dz = abs(z2 - z1)

	var xs := 1 if x2 > x1 else -1
	var ys := 1 if y2 > y1 else -1
	var zs := 1 if z2 > z1 else -1

	if dx >= dy and dx >= dz:
		var p1 = 2 * dy - dx
		var p2 = 2 * dz - dx
		while x1 != x2:
			points.append(Vector3i(x1, y1, z1))
			x1 += xs
			if p1 >= 0:
				y1 += ys
				p1 -= 2 * dx
			if p2 >= 0:
				z1 += zs
				p2 -= 2 * dx
			p1 += 2 * dy
			p2 += 2 * dz

	elif dy >= dx and dy >= dz:
		var p1 = 2 * dx - dy
		var p2 = 2 * dz - dy
		while y1 != y2:
			points.append(Vector3i(x1, y1, z1))
			y1 += ys
			if p1 >= 0:
				x1 += xs
				p1 -= 2 * dy
			if p2 >= 0:
				z1 += zs
				p2 -= 2 * dy
			p1 += 2 * dx
			p2 += 2 * dz

	else:
		var p1 = 2 * dy - dz
		var p2 = 2 * dx - dz
		while z1 != z2:
			points.append(Vector3i(x1, y1, z1))
			z1 += zs
			if p1 >= 0:
				y1 += ys
				p1 -= 2 * dz
			if p2 >= 0:
				x1 += xs
				p2 -= 2 * dz
			p1 += 2 * dy
			p2 += 2 * dx

	points.append(Vector3i(x2, y2, z2))
	return points
