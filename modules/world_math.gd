class_name WorldMath

static func shape_burst(target_entities, user, reach):
	for creature in Global.world_manager.current_world.creatures:
		var distance_ok = char_in_range(user, creature, reach)
		var visible = has_line_of_sight(user, creature)
		if distance_ok and visible:
			target_entities.append(creature)

static func char_in_range(user: Node, target: Node, reach: int) -> bool:
	var user_coords = Vector2i(user.data.tile_x, user.data.tile_y)
	var target_coords = Vector2i(target.data.tile_x, target.data.tile_y)

	var dx = abs(user_coords.x - target_coords.x)
	var dy = abs(user_coords.y - target_coords.y)
	
	var result = floor(sqrt(dx * dx + dy * dy))
	return result <= reach

static func dist_sq_weighted_3d(a: Vector3i, b: Vector3i, z_weight: int = 2) -> int:
	var dx := a.x - b.x
	var dy := a.y - b.y
	var dz := (a.z - b.z) * z_weight
	return dx * dx + dy * dy + dz * dz

static func dist_weighted_3d(a: Vector3i, b: Vector3i, z_weight: int = 2) -> float:
	return sqrt(dist_sq_weighted_3d(a, b, z_weight))

static func pos_in_range_weighted_3d(a: Vector3i, b: Vector3i, reach: int, z_weight: int = 2) -> bool:
	return dist_sq_weighted_3d(a, b, z_weight) <= reach * reach

#static func is_in_range_squared(user: Node, target: Node, reach: int) -> bool:
	#var dx = user.data.tile_x - target.data.tile_x
	#var dy = user.data.tile_y - target.data.tile_y
	#
	#var dist_sq = dx * dx + dy * dy
	#var reach_sq = reach * reach
	#
	#return dist_sq <= reach_sq

#static func pos_is_in_range(origin: Vector2i, target: Vector2i, reach: int) -> bool:
	#var dx = abs(origin.x - target.x)
	#var dy = abs(origin.y - target.y)
	#
	#var result = floor(sqrt(dx * dx + dy * dy))
	#return result <= reach
#
#static func pos_in_range_squared(origin: Vector2i, target: Vector2i, reach: int) -> bool:
	#var dx = origin.x - target.x
	#var dy = origin.y - target.y
	#
	#var dist_sq = dx * dx + dy * dy
	#var reach_sq = reach * reach
	#
	#return dist_sq <= reach_sq

static func has_line_of_sight(origin_char, target_char):
	var vm = Global.world_manager
	var origin = vm.get_char_coords(origin_char)
	var target = vm.get_char_coords(target_char)
	return line_of_sight_exists(origin.vec3.x, origin.vec3.y, origin.vec3.z, target.vec3.x, target.vec3.y, target.vec3.z)

static func has_line_of_sight_tile(origin_tile: Vector3i, target_tile: Vector3i) -> bool:
	return line_of_sight_exists(origin_tile.x, origin_tile.y, origin_tile.z, target_tile.x, target_tile.y, target_tile.z)

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
