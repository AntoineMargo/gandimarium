extends Node

class_name WorldManager

var layers: Dictionary = {}
var layer_links: Dictionary = {}
var current_tile_map_layer: TileMapLayer = null
var current_level: int = 0
var current_world: Node = null
var local_timer: Timer = Timer.new() 
var spawner: Spawner

var target_highlights = []

@onready var selection_highlight = load("res://interface/local_map/selection_highlight.tscn").instantiate()

func setup_layers():
	layers.clear()
	for child in current_world.get_children():
		if child is TileMapLayer:
			var layer = child
			var id = layer.id
			var astar = AStarGrid2D.new()
			var tile_map_limits = layer.get_used_rect()
			var width = tile_map_limits.size.x
			var height = tile_map_limits.size.y
			var contents = {};
			var occupied = {};
			var hit_points = {};
			var item_visual = {};
			astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
			astar.region = Rect2i(0, 0, width, height)
			astar.cell_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
			astar.update()
			for x in range(width):
				for y in range(height):
					var coords = Vector2i(x, y)
					var tile_data = layer.get_cell_tile_data(coords)
					if tile_data and tile_data.get_custom_data("walkable") == false:
						astar.set_point_solid(coords, true)
			layers[id] = {
				"tile_map": layer,
				"path_map": astar,
				"contents": contents,
				"occupied": occupied,
				"hit_points": hit_points,
				"item_visual": item_visual
			}
	if not layers.is_empty():
		current_level = 0
		current_tile_map_layer = layers[current_level]["tile_map"]
		print("Layers set up!")
	else:
		print("Layers is not set up...")

	for z in layers:
		var layer = layers[z]["tile_map"]
		var width = layer.get_used_rect().size.x
		var height = layer.get_used_rect().size.y
		layer_links[z] = {}

		for x in range(width):
			for y in range(height):
				var pos = Vector2i(x, y)
				var tile_data = layer.get_cell_tile_data(pos)
				if tile_data:
					if tile_data.get_custom_data("ramp_up"):
						var up_z = z + 1
						if layers.has(up_z):
							if not layer_links[z].has(pos):
								layer_links[z][pos] = []
							layer_links[z][pos].append([up_z, pos])
					if tile_data.get_custom_data("ramp_down"):
						var down_z = z - 1
						if layers.has(down_z):
							if not layer_links[z].has(pos):
								layer_links[z][pos] = []
							layer_links[z][pos].append([down_z, pos])

func get_reachable_tiles_3D_with_diagonals(start: Vector3i, max_cost: float) -> Array[Vector3i]:
	var visited: Dictionary = {}
	var reachable: Array[Vector3i] = []
	var open := [ { "pos": start, "cost": 0.0 } ]

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
		var cost: float = current.cost

		if visited.has(pos) and visited[pos] <= cost:
			continue

		visited[pos] = cost
		reachable.append(pos)

		var z := pos.z
		var xy := Vector2i(pos.x, pos.y)
		var astar := layers[z]["path_map"] as AStarGrid2D

		# Cardinal neighbors (1.0x cost)
		for dir in cardinal_dirs:
			var neighbor_xy = xy + dir
			var neighbor := Vector3i(neighbor_xy.x, neighbor_xy.y, z)

			if not astar.region.has_point(neighbor_xy):
				continue
			if astar.is_point_solid(neighbor_xy):
				continue

			var move_cost := astar.get_point_weight_scale(neighbor_xy)
			if move_cost <= 0:
				continue

			var new_cost := cost + move_cost
			if new_cost <= max_cost:
				open.append({ "pos": neighbor, "cost": new_cost })

		# Diagonal neighbors (1.5x cost)
		for dir in diagonal_dirs:
			var neighbor_xy = xy + dir
			var neighbor := Vector3i(neighbor_xy.x, neighbor_xy.y, z)

			if not astar.region.has_point(neighbor_xy):
				continue
			if astar.is_point_solid(neighbor_xy):
				continue

			var side1 := Vector2i(dir.x, 0)
			var side2 := Vector2i(0, dir.y)
			if astar.is_point_solid(xy + side1) or astar.is_point_solid(xy + side2):
				continue

			var move_cost := astar.get_point_weight_scale(neighbor_xy)
			if move_cost <= 0:
				continue

			var new_cost := cost + move_cost * 1.5
			if new_cost <= max_cost:
				open.append({ "pos": neighbor, "cost": new_cost })

		# Vertical ramps/stairs
		if layer_links.has(z) and layer_links[z].has(xy):
			for link in layer_links[z][xy]:
				var new_z = link[0]
				var new_xy = link[1]
				var neighbor := Vector3i(new_xy.x, new_xy.y, new_z)

				var new_astar = layers[new_z]["path_map"]
				if not new_astar.region.has_point(new_xy):
					continue
				if new_astar.is_point_solid(new_xy):
					continue

				var move_cost = new_astar.get_point_weight_scale(new_xy)
				if move_cost <= 0:
					continue

				var new_cost = cost + move_cost  # Optional: stairs might be more expensive
				if new_cost <= max_cost:
					open.append({ "pos": neighbor, "cost": new_cost })

	reachable.erase(start)
	return reachable

func is_tile_occupied(coords):
	if layers[current_level]["occupied"][coords.vec2]:
		return true

func show_reachable_tiles():
	if not Global.selected_char:
		return
	var char = Global.selected_char.data
	for coords in char.reachable_tiles:
		if coords.z != current_level:
			continue
		var coords_2d = Vector2i(coords[0], coords[1])
		var painted_scene = preload("res://interface/local_map/painted_tile_effect.tscn")
		var painted_instance = painted_scene.instantiate()
		painted_instance.add_to_group("reachable_overlay")
		
		var tilemap = layers[current_level]["tile_map"]
		var world_pos = tilemap.map_to_local(coords_2d)
		painted_instance.position = world_pos
		
		tilemap.add_child(painted_instance)

func clear_reachable_tiles():
	for node in get_tree().get_nodes_in_group("reachable_overlay"):
		node.queue_free()

func build_reachable_tiles():
	if not Global.focus_char:
		return
	var char = Global.focus_char
	var size = char.data.current_mp
	var coords = get_char_coords(char)
	#char.data.reachable_tiles = get_reachable_tiles_with_diagonals(layers[coords.vec3.z]["path_map"], coords.vec2, size)
	char.data.reachable_tiles = get_reachable_tiles_3D_with_diagonals(coords.vec3, size)

func add_item_visual(coords):
	if not layers[current_level]["item_visual"].has(coords.vec2):
		var visual_scene = preload("res://items/item_on_tile.tscn")
		var visual_instance = visual_scene.instantiate()
		#visual_instance.item = item
		visual_instance.position = current_tile_map_layer.map_to_local(coords.vec2)
		current_tile_map_layer.add_child(visual_instance)
		layers[current_level]["item_visual"][coords.vec2] = visual_instance
		print("Item VISUAL just added to tile.")

func update_layer_visibility():
	for id in layers.keys():
		var layer_data = layers[id]
		if layer_data:
			layer_data["tile_map"].visible = (id == current_level)

func change_level(direction: int):
	if layers.is_empty():
		return
		
	var ids = layers.keys()
	ids.sort()

	var index = ids.find(current_level)
	if index == -1:
		index = 0
	
	index = clamp(index + direction, 0, ids.size() - 1)
	current_level = ids[index]
	update_layer_visibility()
	current_tile_map_layer = layers[current_level]["tile_map"]
	selection_highlight.update_selection_highlight()
	SignalBus.refresh_reachable_tiles.emit()
	print("Now showing layer %d" % current_level)

func calculate_path_cost_3D(path: Array[Vector3i], tile_size: int = Global.TILE_SIZE) -> float:
	if path.size() <= 1:
		return 0.0
	
	var total_cost = 0.0

	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]

		# Normalize to tile-space
		var prev_tile = Vector2i(prev.x / tile_size, prev.y / tile_size)
		var curr_tile = Vector2i(curr.x / tile_size, curr.y / tile_size)
		var delta = curr_tile - prev_tile

		var step_cost = 1.0
		var is_diagonal = abs(delta.x) == 1 and abs(delta.y) == 1 and prev.z == curr.z
		if is_diagonal:
			step_cost = 1.5

		# Optional: adjust cost for vertical movement
		elif prev.z != curr.z:
			step_cost = 1.0  # Or set to 2.0 if stairs are "harder"

		#print("Step ", i, ": ", prev, " → ", curr, " | delta: ", delta, " | diagonal: ", is_diagonal, " | cost: ", step_cost)

		total_cost += step_cost
	
	return total_cost

func turn_path_from_pixels_to_tiles(path: Array[Vector3i], tile_size: int = Global.TILE_SIZE):
	var tile_path = []
	for element in path:
		tile_path.append(Vector3i(element.x / tile_size, element.y / tile_size, element.z))
	
	return tile_path

func calculate_path_cost_3D_simple(path) -> float:
	if path.size() <= 1:
		return 0.0
	
	var total_cost = 0.0

	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]

		# Normalize to tile-space
		var prev_tile = Vector2i(prev.x, prev.y)
		var curr_tile = Vector2i(curr.x, curr.y)
		var delta = curr_tile - prev_tile

		var step_cost = 1.0
		var is_diagonal = abs(delta.x) == 1 and abs(delta.y) == 1 and prev.z == curr.z
		if is_diagonal:
			step_cost = 1.5

		# Optional: adjust cost for vertical movement
		elif prev.z != curr.z:
			step_cost = 1.0  # Or set to 2.0 if stairs are "harder"

		#print("Step ", i, ": ", prev, " → ", curr, " | delta: ", delta, " | diagonal: ", is_diagonal, " | cost: ", step_cost)

		total_cost += step_cost
	
	return total_cost

func find_path_index_by_cost(path, move_budget):
	"takes a path array, a movement budget, and returns the indice of the portion of the path that can be paid for"
	if move_budget <= 0:
		return 0

	var accumulated_cost = 0.0
	for i in range(path.size() - 1):
		var current_tile = path[i]
		var next_tile = path[i + 1]

		var dx = abs(next_tile[0] - current_tile[0])
		var dy = abs(next_tile[1] - current_tile[1])
		var step_cost = 1.5 if (dx > 0 and dy > 0) else 1.0 # should modify and centralize this logic when I introduce difficult terrain
		
		if accumulated_cost + step_cost > move_budget:
			return i
		accumulated_cost += step_cost
	
	return path.size() - 1

func path_to_target_adjacency(creature, target, distance):
	"finds best path from creature to a tile at X distance of target"
	var origin = get_char_coords(target)
	var goal = get_char_coords(creature)
	var path = null
	var tile_path = null
	path = get_multi_level_path(origin.vec3, goal.vec3, true)
	tile_path = turn_path_from_pixels_to_tiles(path)
	
	if tile_path.is_empty():
		print("No path found!")
		return

	tile_path.reverse()
	for i in range(distance):
		tile_path.pop_back()

	return tile_path

func get_multi_level_path(start: Vector3i, goal: Vector3i, allow_occupied_goal: bool = false) -> Array[Vector3i]:
	"returns path array of steps to goal tile by tile in (x, y) format BY PIXEL"
	
	var was_occupied = false
	var goal_xy: Vector2i = Vector2i(goal.x, goal.y)

	if allow_occupied_goal and layers[goal.z]["occupied"][goal_xy] == true:
		#print("tile was occupied.")
		was_occupied = true
		layers[goal.z]["occupied"][goal_xy] = false
		layers[goal.z]["path_map"].set_point_solid(goal_xy, false)

	var path_array: Array = []
	var visited: Dictionary = {}
	var success = _find_recursive_path(start, goal, path_array, visited)

	if was_occupied:
		layers[goal.z]["occupied"][goal_xy] = true
		layers[goal.z]["path_map"].set_point_solid(goal_xy, true)

	if not success:
		return []

	var full_path: Array[Vector3i] = []
	for segment in path_array:
		full_path.append_array(segment)

	return full_path

func get_tile_coords() -> Dictionary:
	var screen_mouse_pos = get_viewport().get_mouse_position()
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_mouse_pos = canvas_transform.affine_inverse() * screen_mouse_pos
	var coords_2d = Vector2i(current_tile_map_layer.local_to_map(world_mouse_pos))
	var coords_3d = Vector3i(coords_2d[0], coords_2d[1], current_level)
	return {
		"vec3": coords_3d,
		"vec2": coords_2d
	}

func turn_3D_coords_into_vector_array(coords):
	var coords_2d = Vector2i(coords.x, coords.y)
	return {
		"vec3": coords,
		"vec2": coords_2d
	}

func get_char_coords(character) -> Dictionary:
	var pos_3d = Vector3i(
	character.data.tile_x,
	character.data.tile_y,
	character.data.map_layer_id)
	return {
		"vec3": pos_3d,
		"vec2": Vector2i(pos_3d.x, pos_3d.y)
	}

func add_to_tile(element, coords):
	var layers = layers
	if not layers[coords.vec3.z]["contents"].has(coords.vec2):
		layers[coords.vec3.z]["contents"][coords.vec2] = []
	layers[coords.vec3.z]["contents"][coords.vec2].append(element)

func remove_from_tile(element, coords):
	if layers[coords.vec3.z]["contents"].has(coords.vec2):
		var contents = layers[coords.vec3.z]["contents"][coords.vec2]
		if element in contents:
			contents.erase(element)
			
			var still_has_items := false
			for other in contents:
				if other is Item:
					still_has_items = true
			if not still_has_items and layers[coords.vec3.z]["item_visual"].has(coords.vec2):
				remove_item_visual(coords)

func remove_item_visual(coords):
	var visual = layers[coords.vec3.z]["item_visual"].get(coords.vec2)
	if visual:
		visual.queue_free()
		layers[coords.vec3.z]["item_visual"].erase(coords.vec2)

func flash_tile_overlay(tile_pos: Vector2i) -> void:
	var flash_scene = preload("res://interface/local_map/flash_tile_effect.tscn")
	var flash_instance = flash_scene.instantiate()
	
	var tilemap = layers[current_level]["tile_map"]
	var world_pos = tilemap.map_to_local(tile_pos)
	flash_instance.position = world_pos
	
	tilemap.add_child(flash_instance)
	flash_instance.get_node("AnimationPlayer").play("flash")
	
func update_creatures_visibility():
	if current_world:
		for creature in current_world.creatures:
			creature.visible = (creature.data.map_layer_id == current_level)

func spawn_player():
	spawner.spawn_character_player()
	
func spawn_enemy():
	spawner.spawn_character_enemy()

#func is_tile_walkable(tilemap: TileMap, world_pos: Vector2) -> bool:
	#var coords = tilemap.local_to_map(world_pos)
	#var data = tilemap.get_cell_tile_data(0, coords)
	#return data != null and data.get_custom_data("walkable") == true

func _on_refresh_reachable_tiles():
	clear_reachable_tiles()
	build_reachable_tiles()
	show_reachable_tiles()

func _find_recursive_path(start: Vector3i, goal: Vector3i, path_array: Array, visited: Dictionary) -> bool:
	var key = str(start)
	if visited.has(key):
		return false
	visited[key] = true

	if start.z == goal.z:
		var path2D: PackedVector2Array = layers[start.z]["path_map"].get_point_path(Vector2i(start.x, start.y), Vector2i(goal.x, goal.y))
		if path2D.is_empty():
			return false
		var path_3d: Array[Vector3i] = []
		for p in path2D:
			path_3d.append(Vector3i(p.x, p.y, start.z))
		path_array.append(path_3d)
		return true

	# Look for ramps on this level
	if not layer_links.has(start.z):
		return false

	for ramp_xy in layer_links[start.z].keys():
		var path2ramp: PackedVector2Array = layers[start.z]["path_map"].get_point_path(Vector2i(start.x, start.y), ramp_xy)
		if path2ramp.is_empty():
			continue
		var path_3d: Array[Vector3i] = []
		for p in path2ramp:
			path_3d.append(Vector3i(p.x, p.y, start.z))
		path_array.append(path_3d)

		for link in layer_links[start.z][ramp_xy]:
			var next_z: int = link[0]
			var next_pos: Vector2i = link[1]
			var new_start = Vector3i(next_pos.x, next_pos.y, next_z)

			if _find_recursive_path(new_start, goal, path_array, visited):
				return true

		# Backtrack if this ramp path didn't work out
		path_array.pop_back()

	return false

func _try_move_char_abs(target):
	if not Global.focus_char:
		return
	var char = Global.focus_char
	var origin = get_char_coords(char)

	layers[origin.vec3.z]["occupied"][origin.vec2] = false
	layers[origin.vec3.z]["path_map"].set_point_solid(origin.vec2, false)
	remove_from_tile(char, origin)
	
	char.data.tile_x = target.vec3.x
	char.data.tile_y = target.vec3.y
	char.data.map_layer_id = target.vec3.z
	char.position = layers[target.vec3.z]["tile_map"].map_to_local(target.vec2)

	layers[target.vec3.z]["occupied"][target.vec2] = true
	add_to_tile(char, target)
	layers[target.vec3.z]["path_map"].set_point_solid(target.vec2, true)

func _on_world_select():
	var coords = get_tile_coords()
	if layers[current_level]["contents"].has(coords.vec2):
		for element in layers[current_level]["contents"][coords.vec2]:
			if element is Creature:
				Global.selected_char = element
				Global.focus_char = element
				selection_highlight.update_selection_highlight()
				SignalBus.update_inventory.emit()
				SignalBus.update_ui_for_char.emit()
				SignalBus.refresh_reachable_tiles.emit()
				print("Selected character: ", element.data.name)
				return

func _on_world_interact():
	var coords = get_tile_coords()
	if Global.selected_char:
		if layers[current_level]["occupied"].get(coords.vec2):
			_interact_attack(coords)
		else:
			_interact_move(coords)

func _interact_attack(coords):
	var target: Creature
	for element in layers[coords.vec3.z]["contents"].get(coords.vec2):
		if element is Creature:
			target = element
			break
	if not target:
		return
	print("===calling perform attak===")
	Global.focus_char.data.perform_attack(target)

func _interact_move(t_coords):
	var char = Global.focus_char
	var o_coords = get_char_coords(char)
	var path = null
	var cost: float = 0
	var path_map = layers[t_coords.vec3.z]["path_map"]
	if not path_map.region.has_point(t_coords.vec2) or path_map.is_point_solid(t_coords.vec2) or layers[t_coords.vec3.z]["occupied"].get(t_coords.vec2):
		print("Invalid target location.")
		return

	print("origin: %d/%d" % [o_coords.vec2.x, o_coords.vec2.y])
	print("goal: %d/%d" % [t_coords.vec2.x, t_coords.vec2.y])

	path = get_multi_level_path(o_coords.vec3, t_coords.vec3)

	if path.is_empty():
		print("No path found!")
		return
	
	var tile_path = turn_path_from_pixels_to_tiles(path)
	cost = calculate_path_cost_3D_simple(tile_path)
	print("Path length: ", path.size() - 1, " steps.")
	print("Path cost: ", cost)
	if Global.crisis_manager.crisis_mode:
		if cost > char.data.current_mp:
			SignalBus.dialog_show_message.emit("You do not have enough movements points.")
			return
		else:
			char.data.current_mp -= cost
	_try_move_char_abs(t_coords)
	update_creatures_visibility()
	clear_reachable_tiles()
	build_reachable_tiles()
	show_reachable_tiles()
	selection_highlight.update_selection_highlight()
	SignalBus.update_ui_for_char.emit()
	
	for point in path:
		point[0] /= Global.TILE_SIZE
		point[1] /= Global.TILE_SIZE
		print("Tile (%d:%d:%d)" % [point[0], point[1], point[2]])
		if point[2] == current_level:
			var point_coords = Vector2i(point[0], point[1])
			flash_tile_overlay(point_coords)

func _on_local_timeout():
	SignalBus.local_turn_passed.emit()

func _on_crisis_mode_started():
	local_timer.paused = true

func _on_crisis_mode_ended():
	local_timer.paused = false

func _ready() -> void:
	selection_highlight.update_selection_highlight()
	spawner = Spawner.new()
	spawner.wm = self
	SignalBus.world_select.connect(_on_world_select)
	SignalBus.world_interact.connect(_on_world_interact)
	SignalBus.refresh_reachable_tiles.connect(_on_refresh_reachable_tiles)
	SignalBus.start_crisis_mode.connect(_on_crisis_mode_started)
	SignalBus.end_crisis_turn.connect(_on_crisis_mode_started)
	local_timer.wait_time = 6.0
	local_timer.autostart = true
	#local_timer.start()
	local_timer.timeout.connect(_on_local_timeout)
