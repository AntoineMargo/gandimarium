class_name WorldMath

#static func get_line_tiles(origin: Vector3i, target: Vector3i) -> Array[Vector3i]:
	#var points = bresenham_line_3d(origin.x, origin.y, origin.z, target.x, target.y, target.z)
	#
	#return points

static func get_line_tiles(origin: Vector3i, target: Vector3i, reach: float) -> Array[Vector3i]:
	var line: Array[Vector3i] = bresenham_line_3d(origin.x, origin.y, origin.z, target.x, target.y, target.z)
	
	var tiles: Array[Vector3i] = []
	
	for i in range(0, line.size()): # skip origin
		var p: Vector3i = line[i]
		
		var dx: int = p.x - origin.x
		var dy: int = p.y - origin.y
		var dist: float = sqrt(dx * dx + dy * dy)
		
		if dist > reach:
			break
		
		tiles.append(p)

	return tiles

static func get_cone_tiles(origin: Vector3i, target: Vector3i, reach: float, spread_degrees: float) -> Array[Vector3i]:
	var wm = Global.world_manager
	var visited: Dictionary = {}
	var tiles: Array[Vector3i] = []
	var open: Array = [{"pos": origin, "dist": 0.0}]
	
	var cardinal_dirs: Array[Vector2i] = [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	var diagonal_dirs: Array[Vector2i] = [
		Vector2i(-1, -1),
		Vector2i(-1, 1),
		Vector2i(1, -1),
		Vector2i(1, 1)
	]

	# Forward direction
	var forward := (Vector2(target.x - origin.x, target.y - origin.y)).normalized()
	var half_spread := deg_to_rad(spread_degrees * 0.5)

	while open.size() > 0:
		var current = open.pop_front()
		var pos: Vector3i = current.pos
		var dist: float = current.dist
		
		if visited.has(pos):
			continue
		
		visited[pos] = true
		
		# Direction from origin to tile
		var to_tile := Vector2(pos.x - origin.x, pos.y - origin.y)
		
		if to_tile.length() > 0:
			var dir := to_tile.normalized()
			var angle := acos(forward.dot(dir))
			
			if angle > half_spread:
				continue
		
		# LOS check
		if pos != origin and not has_line_of_sight_tile(origin, pos):
			continue
		
		tiles.append(pos)
		
		if dist >= reach:
			continue
		
		var z := pos.z
		var xy := Vector2i(pos.x, pos.y)
		var astar := wm.layers[z]["path_map"] as AStarGrid2D
		
		# Cardinal neighbors
		for dir in cardinal_dirs:
			var neighbor_xy := xy + dir
			var neighbor := Vector3i(neighbor_xy.x, neighbor_xy.y, z)
			
			if not astar.region.has_point(neighbor_xy):
				continue
			
			var tile_data = get_tile_data(neighbor.x, neighbor.y, neighbor.z)
			if tile_data == null or tile_data.get_custom_data("passable") == false:
				continue
			
			open.append({"pos": neighbor, "dist": dist + 1.0})
		
		# Diagonal neighbors
		for dir in diagonal_dirs:
			var neighbor_xy := xy + dir
			var neighbor := Vector3i(neighbor_xy.x, neighbor_xy.y, z)
			
			if not astar.region.has_point(neighbor_xy):
				continue
			
			var tile_data = get_tile_data(neighbor.x, neighbor.y, neighbor.z)
			if tile_data == null or tile_data.get_custom_data("passable") == false:
				continue
			
			open.append({"pos": neighbor, "dist": dist + 1.5})
	
	tiles.pop_front()
	return tiles

static func get_burst_tiles(center: Vector3i, reach: float) -> Array[Vector3i]:
	var wm = Global.world_manager
	var visited: Dictionary = {}
	var tiles: Array[Vector3i] = []
	var open := [{"pos": center, "dist": 0.0}]
	
	var cardinal_dirs := [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]
	var diagonal_dirs := [
		Vector2i(-1, -1),
		Vector2i(-1, 1),
		Vector2i(1, -1),
		Vector2i(1, 1)
	]
	
	while open.size() > 0:
		var current = open.pop_front()
		var pos: Vector3i = current.pos
		var dist: float = current.dist
		
		if visited.has(pos):
			continue
		
		# Check line of sight from center
		if pos != center and not has_line_of_sight_tile(center, pos):
			continue
		
		visited[pos] = true
		tiles.append(pos)
		
		# Don't expand from max reach tiles
		if dist >= reach:
			continue
		
		var z := pos.z
		var xy := Vector2i(pos.x, pos.y)
		var astar := wm.layers[z]["path_map"] as AStarGrid2D
		
		# Cardinal neighbors (cost 1.0)
		for dir in cardinal_dirs:
			var neighbor_xy = xy + dir
			var neighbor := Vector3i(neighbor_xy.x, neighbor_xy.y, z)
			
			if not astar.region.has_point(neighbor_xy):
				continue
			
			var tile_data = get_tile_data(neighbor.x, neighbor.y, neighbor.z)
			if tile_data == null or tile_data.get_custom_data("passable") == false:
				continue
			
			open.append({"pos": neighbor, "dist": dist + 1.0})
		
		# Diagonal neighbors (cost 1.5 for more circular shape)
		for dir in diagonal_dirs:
			var neighbor_xy = xy + dir
			var neighbor := Vector3i(neighbor_xy.x, neighbor_xy.y, z)
			
			if not astar.region.has_point(neighbor_xy):
				continue
			
			var tile_data = get_tile_data(neighbor.x, neighbor.y, neighbor.z)
			if tile_data == null or tile_data.get_custom_data("passable") == false:
				continue
			
			open.append({"pos": neighbor, "dist": dist + 1.5})
	
	return tiles

static func get_entities_from_tiles(tiles: Array[Vector3i]) -> Array:
	var wm = Global.world_manager
	var target_entities = []
	for tile in tiles:
		var entity
		entity = wm.get_entity_at_pos(tile)
		if entity:
			target_entities.append(entity)

	return target_entities

static func get_creatures_from_tiles(tiles: Array[Vector3i]) -> Array:
	var wm = Global.world_manager
	var target_creatures = []
	for tile in tiles:
		var creature: Creature
		creature = wm.get_creature_at_pos(tile)
		if creature:
			target_creatures.append(creature)

	return target_creatures

static func shape_burst_entities(target_tile: Vector3i, reach: int) -> Array:
	var target_entities = []
	var wm = Global.world_manager
	var tiles = get_burst_tiles(target_tile, reach)
	
	#wm.visualize_area(tiles)
	
	for tile in tiles:
		var creature: Creature
		creature = wm.get_creature_at_pos(tile)
		if creature:
			target_entities.append(creature)
	
	return target_entities

static func shape_burst(target_entities, user, reach):
	for creature in Global.world_manager.current_world.creatures:
		var distance_ok = char_in_range(user, creature, reach)
		var visible = has_line_of_sight(user, creature)
		if distance_ok and visible:
			target_entities.append(creature)

static func is_in_range(origin: Vector3i, target: Vector3i, reach: int) -> bool:
	var dx = abs(origin.x - target.x)
	var dy = abs(origin.y - target.y)
	
	var result = floor(sqrt(dx * dx + dy * dy))
	return result <= reach

static func char_in_range(user: Node, target: Node, reach: int) -> bool:
	var user_coords = user.get_coords()
	var target_coords = target.get_coords()

	var dx = abs(user_coords.x - target_coords.x)
	var dy = abs(user_coords.y - target_coords.y)
	
	var result = floor(sqrt(dx * dx + dy * dy))
	return result <= reach

static func dist_sq_weighted_3d(a: Vector3i, b: Vector3i, z_weight: int = 2) -> int:
	var dx = a.x - b.x
	var dy = a.y - b.y
	var dz = (a.z - b.z) * z_weight
	return dx * dx + dy * dy + dz * dz

static func dist_weighted_3d(a: Vector3i, b: Vector3i, z_weight: int = 2) -> float:
	return sqrt(dist_sq_weighted_3d(a, b, z_weight))

static func pos_in_range_weighted_3d(a: Vector3i, b: Vector3i, reach: int, z_weight: int = 2) -> bool:
	return dist_sq_weighted_3d(a, b, z_weight) <= reach * reach

static func has_line_of_sight(origin_node, target_node):
	var origin = origin_node.get_coords()
	var target = target_node.get_coords()
	return line_of_sight_exists(origin.x, origin.y, origin.z, target.x, target.y, target.z)

static func has_line_of_sight_tile(origin_tile: Vector3i, target_tile: Vector3i) -> bool:
	return line_of_sight_exists(origin_tile.x, origin_tile.y, origin_tile.z, target_tile.x, target_tile.y, target_tile.z)

static func line_of_sight_exists(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int) -> bool:
	var wm = Global.world_manager
	
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
			#if tile == null or tile.get_custom_data("passable") == false:
			if wm.layers[z]["cover"].get(Vector2i(x, y), 0) == 4:
				return false

	return true

static func get_tile_data(x: int, y: int, z: int):
	var wm = Global.world_manager
	var layer = wm.layers.get(z)
	if not layer:
		return null
	var tile_map: TileMapLayer = layer["tile_map"]
	return tile_map.get_cell_tile_data(Vector2i(x, y))

static func bresenham_line_3d(x1: int, y1: int, z1: int, x2: int, y2: int, z2: int) -> Array[Vector3i]:
	var points: Array[Vector3i] = []

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
