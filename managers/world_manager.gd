extends Node
class_name WorldManager

var layers: Dictionary = {}
var layer_links: Dictionary = {}
var ai_zones: Dictionary = {}
var current_tile_map_layer: TileMapLayer = null
var current_level: int = 0
var current_world: Node = null
var map_state = null
var spawner: Spawner

var map_width: int
var map_height: int

var world_ready: bool = false

var target_highlights = []

var PathPreviewScene = preload("res://interface/local_map/path_preview.tscn")
var path_preview: Node2D = null

var preview_visualized_rects: Array[ColorRect] = []
var preview_visualized_lines: Array[Line2D] = []

var committed_visualized_rects: Array[ColorRect] = []
var committed_visualized_lines: Array[Line2D] = []

var VFX_scenes: Array = []

@onready var selection_highlight = load("res://interface/local_map/selection_highlight/selection_highlight.tscn").instantiate()
@onready var hover_tile = load("res://interface/local_map/hover_tile_indicator/hover_tile_indicator.tscn").instantiate()

enum ElementPriority {
	CREATURE = 4,
	ITEM = 3,
	PROP = 2,
	AREA_CONDITION = 1
}

func _process(_delta):
	if get_viewport().gui_get_hovered_control():
		hover_tile.stop_drawing()
		path_preview.clear_all()
		return

	if not current_world:
		return

	hover_tile.start_drawing()
	var tile_under_cursor = get_hovered_tile()
	Global.handle_world_hover(tile_under_cursor)
	if Global.activity_handler:
		return
	if Global.crisis_manager.crisis_mode and Global.selected_char:
		preview_path(tile_under_cursor)

func spawn_prop(scene: PackedScene, pos: Vector3i) -> Prop:
	var prop: Prop = scene.instantiate()
	prop.scene = scene
	prop.is_runtime = true
	prop.pos = pos

	for layer in current_world.get_children():
		print("layer id: %d" % layer.id)
		if layer.id == pos.z:
			layer.props.add_child(prop)
			prop.global_position = tile_to_pixels(pos)
			prop.initialize()
			break

	Global.state_manager.add_prop_to_delta(prop)
	return prop

func get_entity_at_pos(pos: Vector3i) -> Entity:
	var layer_pos = Vector2i(pos.x, pos.y)
	if layers[pos.z]["contents"].has(layer_pos):
		for element in layers[pos.z]["contents"][layer_pos]:
			if element is Entity:
				return element
	return null

func get_prop_at_pos(pos: Vector3i) -> Prop:
	var layer_pos = Vector2i(pos.x, pos.y)
	if layers[pos.z]["contents"].has(layer_pos):
		for element in layers[pos.z]["contents"][layer_pos]:
			if element is Prop:
				return element
	return null

func get_creature_at_pos(pos: Vector3i) -> Creature:
	var layer_pos = Vector2i(pos.x, pos.y)
	if layers[pos.z]["contents"].has(layer_pos):
		for element in layers[pos.z]["contents"][layer_pos]:
			if element is Creature:
				return element
	return null

func move_prop(old_pos: Vector3i, new_pos: Vector3i):
	var old_prop = get_prop_at_pos(old_pos)
	var new_prop = spawn_prop(old_prop.scene, new_pos)
	new_prop.current_hp = old_prop.current_hp
	new_prop.is_active = old_prop.is_active
	old_prop.destroy_self()

func determine_find_dimensions():
	for child in current_world.get_children():
		if child is TileMapLayer:
			var tile_map_limits = child.get_used_rect()
			map_width = tile_map_limits.size.x
			map_height = tile_map_limits.size.y
			return

func get_tile_data(tile: Vector3i):
	return layers[tile.z]["tile_map"].get_cell_tile_data(Vector2i(tile.x, tile.y))

func get_tile_move_cost(tile: Vector3i) -> float:
	return layers[tile.z]["move_cost"].get(Vector2i(tile.x, tile.y), 1)

func get_tile_contents(tile: Vector3i) -> Array:
	var layer_tile = Vector2i(tile.x, tile.y)
	var contents = layers[tile.z]["contents"]

	var result = contents.get(layer_tile)
	if result == null:
		result = []
		contents[layer_tile] = result

	return result

func change_tile_move_cost(tile: Vector3i, new_cost: float) -> void:
	var layer_tile = Vector2i(tile.x, tile.y)
	layers[tile.z]["move_cost"][layer_tile] = new_cost

func setup_layers():
	layers.clear()
	for child in current_world.get_children():
		if child is TileMapLayer:
			var layer = child
			var id = layer.id
			var astar = AStarGrid2D.new()
			var noise_astar = AStarGrid2D.new()
			var contents = {};
			var occupied = {};
			var cover = {};
			var move_cost = {};
			var hit_points = {};
			var item_visual = {};

			layers[id] = {
				"tile_map": layer,
				"path_map": astar,
				"noise_map": noise_astar,
				"contents": contents,
				"occupied": occupied,
				"cover": cover,
				"move_cost": move_cost,
				"hit_points": hit_points,
				"item_visual": item_visual
			}
			
			astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
			astar.region = layer.get_used_rect()
			astar.cell_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
			astar.update()
			
			noise_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
			noise_astar.region = layer.get_used_rect()
			noise_astar.cell_size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
			noise_astar.update()
			
			var rect = layer.get_used_rect()

			for x in range(rect.position.x, rect.position.x + rect.size.x):
				for y in range(rect.position.y, rect.position.y + rect.size.y):
					var coords = Vector2i(x, y)
					var tile_data = layer.get_cell_tile_data(coords)
					if tile_data:
						var tile_cover = tile_data.get_custom_data("cover")
						if tile_cover == 4:
							layers[id]["cover"][coords] = Enums.Cover.FULL
							astar.set_point_solid(coords, true)
							noise_astar.set_point_weight_scale(coords, 10.0)

	if not layers.is_empty():
		current_level = 0
		current_tile_map_layer = layers[current_level]["tile_map"]
		print("Layers set up!")
	else:
		print("Layers is not set up...")

func setup_ramps():
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

func setup_ai_zones():
	for layer in current_world.get_children():
		if layer is TileMapLayer:
			var id = layer.id
			for child in layer.get_children():
				if child is ZonePainter:
					ai_zones[id] = child.zones

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
		var xy: Vector2i = Vector2i(pos.x, pos.y)
		var astar := layers[z]["path_map"] as AStarGrid2D

		# Cardinal neighbors (1.0x cost)
		for dir in cardinal_dirs:
			var neighbor_xy = xy + dir
			var neighbor: Vector3i = Vector3i(neighbor_xy.x, neighbor_xy.y, z)

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
			var neighbor: Vector3i = Vector3i(neighbor_xy.x, neighbor_xy.y, z)

			if not astar.region.has_point(neighbor_xy):
				continue
			if astar.is_point_solid(neighbor_xy):
				continue

			var side1: Vector2i = Vector2i(dir.x, 0)
			var side2: Vector2i = Vector2i(0, dir.y)
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
				var neighbor: Vector3i = Vector3i(new_xy.x, new_xy.y, new_z)

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

## @deprecated: use get_tile_occupied(tile: Vector3i) instead
func is_tile_occupied(coords):
	if layers[current_level]["occupied"][coords.vec2]:
		return true

#func show_reachable_tiles():
	#if not Global.selected_char:
		#return
	#var character = Global.selected_char
	#for coords in character.reachable_tiles:
		#if coords.z != current_level:
			#continue
		#var coords_2d = Vector2i(coords[0], coords[1])
		#var painted_scene = preload("res://interface/local_map/painted_tile_effect.tscn")
		#var painted_instance = painted_scene.instantiate()
		#painted_instance.add_to_group("reachable_overlay")
		#
		#var tilemap = layers[current_level]["tile_map"]
		#var world_pos = tilemap.map_to_local(coords_2d)
		#painted_instance.position = world_pos
		#
		#tilemap.add_child(painted_instance)
#
#func clear_reachable_tiles():
	#for node in get_tree().get_nodes_in_group("reachable_overlay"):
		#node.queue_free()
#
#func build_reachable_tiles():
	#if not Global.focus_char:
		#return
	#var char = Global.focus_char
	#var size = char.get_stat("current_mp")
	#var coords = get_char_coords(char)
	##char.data.reachable_tiles = get_reachable_tiles_with_diagonals(layers[coords.vec3.z]["path_map"], coords.vec2, size)
	#char.reachable_tiles = get_reachable_tiles_3D_with_diagonals(coords.vec3, size)

func add_item_visual(coords: Vector3i):
	var layer_coords = Vector2i(coords.x, coords.y)
	if not layers[coords.z]["item_visual"].has(layer_coords):
		var visual_scene = preload("res://items/item_on_tile.tscn")
		var visual_instance = visual_scene.instantiate()
		#visual_instance.item = item
		visual_instance.position = current_tile_map_layer.map_to_local(layer_coords)
		current_tile_map_layer.add_child(visual_instance)
		layers[coords.z]["item_visual"][layer_coords] = visual_instance
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
	#SignalBus.refresh_reachable_tiles.emit()
	print("Now showing layer %d" % current_level)

func turn_path_from_pixels_to_tiles(path: Array[Vector3i], tile_size: int = Global.TILE_SIZE):
	var tile_path = []
	for element in path:
		@warning_ignore("integer_division")
		tile_path.append(Vector3i(element.x / tile_size, element.y / tile_size, element.z))
	
	return tile_path

func calculate_path_cost_3D_simple(path) -> float:
	if path.size() <= 1:
		return 0.0
	
	var total_cost = 0.0

	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]

		var prev_tile = Vector2i(prev.x, prev.y)
		var curr_tile = Vector2i(curr.x, curr.y)
		var delta = curr_tile - prev_tile

		var step_cost: float = get_tile_move_cost(curr)
		var is_diagonal = abs(delta.x) == 1 and abs(delta.y) == 1 and prev.z == curr.z
		if is_diagonal:
			step_cost *= 1.5

		# vertical movement
		elif prev.z != curr.z:
			step_cost *= 2.0

		total_cost += step_cost
	
	return total_cost

## Returns an array of floats: movement cost per segment
func turn_path_array_into_cost_array(path: Array) -> Array:
	
	var segment_costs: Array = []

	if path.size() <= 1:
		return segment_costs

	for i in range(1, path.size()):
		var prev = path[i - 1]
		var curr = path[i]

		var prev_tile = Vector2i(prev.x, prev.y)
		var curr_tile = Vector2i(curr.x, curr.y)
		var delta = curr_tile - prev_tile

		var step_cost: float = get_tile_move_cost(curr)
		var is_diagonal = abs(delta.x) == 1 and abs(delta.y) == 1 and prev.z == curr.z
		if is_diagonal:
			step_cost *= 1.5

		# vertical movement
		elif prev.z != curr.z:
			step_cost *= 2.0

		segment_costs.append(step_cost)

	return segment_costs


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

func path_to_adjacency(origin: Vector3i, goal: Vector3i, distance: int):
	var layer_origin = Vector2i(origin.x, origin.y)
	var layer_goal = Vector2i(goal.x, goal.y)
	
	# making characters non-blocking since Godot 4.6 doesn't like that anymore
	layers[origin.z]["path_map"].set_point_solid(layer_origin, false)
	layers[goal.z]["path_map"].set_point_solid(layer_goal, false)
	
	var path = null
	@warning_ignore("unused_variable")
	var tile_path = null
	path = get_multi_level_path(origin, goal, true)
	#tile_path = turn_path_from_pixels_to_tiles(path)
	
	# making characters blocking again
	layers[origin.z]["path_map"].set_point_solid(layer_origin, true)
	layers[goal.z]["path_map"].set_point_solid(layer_goal, true)
	
	if path.is_empty():
		print("No path found!")
		return

	path.reverse()
	for i in range(distance):
		path.pop_back()

	return path

## finds best path from creature to a tile at X distance of target
func path_to_target_adjacency(creature, target, distance):
	var origin = get_char_coords(target)
	var goal = get_char_coords(creature)
	
	# making characters non-blocking since Godot 4.6 doesn't like that anymore
	layers[origin.vec3.z]["path_map"].set_point_solid(origin.vec2, false)
	layers[goal.vec3.z]["path_map"].set_point_solid(goal.vec2, false)
	
	var path = null
	@warning_ignore("unused_variable")
	var tile_path = null
	path = get_multi_level_path(origin.vec3, goal.vec3, true)
	#tile_path = turn_path_from_pixels_to_tiles(path)
	
	# making characters blocking again
	layers[origin.vec3.z]["path_map"].set_point_solid(origin.vec2, true)
	layers[goal.vec3.z]["path_map"].set_point_solid(goal.vec2, true)
	
	if path.is_empty():
		print("No path found!")
		return

	path.reverse()
	for i in range(distance):
		path.pop_back()

	return path

func get_multi_level_path_for_creature(creature: Creature, goal: Vector3i, allow_occupied_goal: bool = false, easy_doors: bool = false) -> Array[Vector3i]:
	if easy_doors:
		Global.door_manager.prepare_doors_for_pathfinding()
	var coords = creature.get_coords()
	var path: Array[Vector3i] = get_multi_level_path(coords, goal, allow_occupied_goal)
	if easy_doors:
		Global.door_manager.reset_doors_to_previous_state()
	return path

## returns path array of steps to goal tile by tile in (x, y) format BY PIXEL... Or not anymore? Not sure.
func get_multi_level_path(start: Vector3i, goal: Vector3i, allow_occupied_goal: bool = false) -> Array[Vector3i]:

	var was_occupied = false
	var goal_xy: Vector2i = Vector2i(goal.x, goal.y)

	if allow_occupied_goal and layers[goal.z]["occupied"].get(goal_xy, false) == true:
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

func get_creature_by_id(target_id) -> Creature:
	return current_world.creatures_by_id.get(target_id, null)

## Returns if a tile is occupied or not
func get_tile_occupied(tile: Vector3i) -> bool:
	var tile_coords: Vector2i = Vector2i(tile.x, tile.y)
	var layer = layers.get(tile.z)
	
	if layer == null:
		push_error("no layer")
		return false
	
	var occupied = layer.get("occupied")
	if occupied == null:
		return false
	
	return occupied.get(tile_coords, false)

func get_hovered_tile() -> Vector3i:
	var screen_mouse_pos = get_viewport().get_mouse_position()
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_mouse_pos = canvas_transform.affine_inverse() * screen_mouse_pos
	var coords_2d = Vector2i(current_tile_map_layer.local_to_map(world_mouse_pos))
	return Vector3i(coords_2d.x, coords_2d.y, current_level)

func get_tile_coords_under_cursor() -> Vector3i:
	var screen_mouse_pos = get_viewport().get_mouse_position()
	var canvas_transform = get_viewport().get_canvas_transform()
	var world_mouse_pos = canvas_transform.affine_inverse() * screen_mouse_pos
	var coords_2d = Vector2i(current_tile_map_layer.local_to_map(world_mouse_pos))
	return Vector3i(coords_2d[0], coords_2d[1], current_level)

## @deprecated: use "get_hovered_tile"
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

## @deprecated: use get_coords(character) from Creature instead
func get_char_coords(character) -> Dictionary:
	var pos_3d = Vector3i(
	character.data.tile_x,
	character.data.tile_y,
	character.data.tile_z)
	return {
		"vec3": pos_3d,
		"vec2": Vector2i(pos_3d.x, pos_3d.y)
	}

func add_to_tile(element, coords: Vector3i):
	var layer_coords = Vector2i(coords.x, coords.y)
	if not layers[coords.z]["contents"].has(layer_coords):
		layers[coords.z]["contents"][layer_coords] = []
	if element is Item:
		element = element.duplicate(true)
		element.count = 1
	layers[coords.z]["contents"][layer_coords].append(element)

func remove_from_tile(element, coords: Vector3i):
	var layer_coords = Vector2i(coords.x, coords.y)
	if layers[coords.z]["contents"].has(layer_coords):
		var contents = layers[coords.z]["contents"][layer_coords]
		if element in contents:
			contents.erase(element)
			
			var still_has_items = false
			for other in contents:
				if other is Item:
					still_has_items = true
			if not still_has_items and layers[coords.z]["item_visual"].has(layer_coords):
				remove_item_visual(coords)

func remove_item_visual(coords: Vector3i):
	var layer_coords = Vector2i(coords.x, coords.y)
	var visual = layers[coords.z]["item_visual"].get(layer_coords)
	if visual:
		visual.queue_free()
		layers[coords.z]["item_visual"].erase(layer_coords)

func flash_tile_overlay(tile_pos: Vector2i) -> void:
	var flash_scene = preload("res://interface/local_map/flash_tile_effect.tscn")
	var flash_instance = flash_scene.instantiate()
	
	var tilemap = layers[current_level]["tile_map"]
	var world_pos = tilemap.map_to_local(tile_pos)
	flash_instance.position = world_pos
	
	tilemap.add_child(flash_instance)
	flash_instance.get_node("AnimationPlayer").play("flash")
	
func creatures_visible_if_on_layer():
	if current_world:
		for creature in current_world.creatures:
			creature.visible = (creature.data.tile_z == current_level)

#func spawn_player():
	#spawner.spawn_character_player()
	#
#func spawn_enemy():
	#spawner.spawn_character_enemy()
	
func spawn_character(data_file: String, coords: Vector3i, routine: String = ""):
	spawner.spawn_character(data_file, coords, routine)

## takes a tile's coords in either Vector3i or Vector2i format and returns them in pixel format
func tile_to_pixels(coords) -> Vector2:
	if coords is Vector3i:
		coords = Vector2i(coords.x, coords.y)
	elif coords is Vector2i:
		pass
	else:
		push_warning("Error: Invalid type")
		return Vector2(-1.0, -1.0)
	return Vector2((coords.x * Global.TILE_SIZE + Global.TILE_SIZE * 0.5), (coords.y * Global.TILE_SIZE + Global.TILE_SIZE * 0.5))

## takes a tile's coords in pixel format and returns it in Vector2i format
## second parameter is optional: the z-level of the location, current_level by default
func pixels_to_tile(coords: Vector2, level: int = current_level) -> Vector3i:
	@warning_ignore("narrowing_conversion")
	return Vector3i(coords.x / Global.TILE_SIZE, coords.y / Global.TILE_SIZE, level)

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
			# Convert from world coordinates to grid coordinates
			@warning_ignore("integer_division")
			path_3d.append(Vector3i(int(p.x) / Global.TILE_SIZE, int(p.y) / Global.TILE_SIZE, start.z))
		path_array.append(path_3d)
		return true
	# Look for ramps on this level
	if not layer_links.has(start.z):
		print("	not layer_links.has(start.z)")
		return false
	for ramp_xy in layer_links[start.z].keys():
		var pm = layers[start.z]["path_map"]
		var start_2d = Vector2i(start.x, start.y)
		var was_solid = pm.is_point_solid(start_2d)
		if was_solid:
			pm.set_point_solid(start_2d, false)
		var path2ramp = pm.get_point_path(start_2d, ramp_xy, true)
		if path2ramp.is_empty():
			continue
		# FIX: Godot 4.6 returns world coordinates, convert back to grid coordinates
		@warning_ignore("integer_division")
		var last_pos = Vector2i(int(path2ramp[-1].x) / Global.TILE_SIZE, int(path2ramp[-1].y) / Global.TILE_SIZE)
		#print("path2ramp last =", last_pos, " expected =", ramp_xy)
		if last_pos != ramp_xy:
			continue
		var path_3d: Array[Vector3i] = []
		for p in path2ramp:
			# Convert from world coordinates to grid coordinates
			@warning_ignore("integer_division")
			path_3d.append(Vector3i(int(p.x) / Global.TILE_SIZE, int(p.y) / Global.TILE_SIZE, start.z))
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

func move_char_along_path(creature: Creature, path: Array[Vector3i]):
	path_preview.make_inactive()
	for i in range(path.size() - 1):
		var current_tile = path[i]
		var layer_current_tile = Vector2i(current_tile.x, current_tile.y)
		var next_tile = path[i + 1]
		var layer_next_tile = Vector2i(next_tile.x, next_tile.y)

		layers[current_tile.z]["cover"][layer_current_tile] = Enums.Cover.NONE
		layers[current_tile.z]["occupied"][layer_current_tile] = false
		layers[current_tile.z]["path_map"].set_point_solid(layer_current_tile, false)
		remove_from_tile(creature, current_tile)

		creature.data.tile_x = next_tile.x
		creature.data.tile_y = next_tile.y
		creature.data.tile_z = next_tile.z

		layers[next_tile.z]["cover"][layer_next_tile] = Enums.Cover.QUARTER
		layers[next_tile.z]["occupied"][layer_next_tile] = true
		layers[next_tile.z]["path_map"].set_point_solid(layer_next_tile, true)
		add_to_tile(creature, next_tile)
		creature.visible = (creature.data.tile_z == current_level)
		creature.global_position = layers[next_tile.z]["tile_map"].map_to_local(layer_next_tile)
		creature.mover.position = Vector2.ZERO # Very necessary because of position/global_position mismatch during real-time move
		handle_tile_conditions(next_tile, creature)
		selection_highlight.update_selection_highlight()
		SignalBus.sight_check.emit(next_tile)
		SignalBus.event.emit(ReactionEvent.movement(Context.movement(creature, current_tile, next_tile)))
		flash_path([current_tile])
		await get_tree().create_timer(0.05).timeout
	path_preview.make_active()

func move_char_to_tile(creature: Creature, origin: Vector3i, target: Vector3i):
	path_preview.clear_all()
	var layer_origin = Vector2i(origin.x, origin.y)
	var layer_target = Vector2i(target.x, target.y)
	
	layers[origin.z]["cover"][layer_origin] = Enums.Cover.NONE
	layers[origin.z]["occupied"][layer_origin] = false
	layers[origin.z]["path_map"].set_point_solid(layer_origin, false)
	remove_from_tile(creature, origin)
	
	creature.data.tile_x = target.x
	creature.data.tile_y = target.y
	creature.data.tile_z = target.z
	
	layers[target.z]["cover"][layer_target] = Enums.Cover.QUARTER
	layers[target.z]["occupied"][layer_target] = true
	layers[target.z]["path_map"].set_point_solid(layer_target, true)
	add_to_tile(creature, target)

func try_move_char_abs(creature: Creature, origin: Vector3i, target: Vector3i):
	move_char_to_tile(creature, origin, target)

func select_creature_on_tile(coordinates: Vector3i) -> bool:
	var layer_coords = Vector2i(coordinates.x, coordinates.y)
	if layers[current_level]["contents"].has(layer_coords):
		for element in layers[current_level]["contents"][layer_coords]:
			if element is Creature:
				if element.data.player_controlled:
					Global.selected_char = element
					Global.focus_char = element
					selection_highlight.update_selection_highlight()
					SignalBus.update_inventory.emit()
					SignalBus.update_character_info.emit()
					SignalBus.update_ui_for_char.emit()
					SignalBus.update_character_window.emit(element)
					print("Selected character: ", element.data.name)
					return true
	return false

func preview_path(to_tile: Vector3i) -> void:
	var to_tile_vec2 = Vector2i(to_tile.x, to_tile.y)
	var character = Global.focus_char
	var o_coords = get_char_coords(character)
	var path = null
	var path_map = layers[to_tile.z]["path_map"]
	if not path_map.region.has_point(to_tile_vec2) or path_map.is_point_solid(to_tile_vec2) or layers[to_tile.z]["occupied"].get(to_tile_vec2):
		path_preview.clear_all()
		print("Preview: Invalid target location.")
		return

	#print("origin: %d/%d" % [o_coords.vec2.x, o_coords.vec2.y])
	#print("goal: %d/%d" % [to_tile.x, to_tile.y])

	path_map.set_point_solid(o_coords.vec2, false)
	path = get_multi_level_path(o_coords.vec3, to_tile)

	if path.is_empty():
		print("No path found!")
		return

	var costs = turn_path_array_into_cost_array(path)
	path_preview.update_path(path, layers[current_level]["tile_map"], costs)

func _get_element_priority(element) -> int:
	if element is Creature:
		return ElementPriority.CREATURE
	if element is Item:
		return ElementPriority.ITEM
	if element is Prop:
		return ElementPriority.PROP
	if element is AreaCondition:
		return ElementPriority.AREA_CONDITION
	return 0

func get_priority_element_on_tile(coords: Vector3i):
	var layer_coords = Vector2i(coords.x, coords.y)
	var elements = layers[coords.z]["contents"].get(layer_coords, [])

	var best = null
	var best_priority: int = -1

	for element in elements:
		var priority = _get_element_priority(element)
		if priority > best_priority:
			best_priority = priority
			best = element

	return best

func _simple_interact_disambiguation(force_interact: bool = false):
	var coords = get_tile_coords_under_cursor()
	if select_creature_on_tile(coords):
		return
	if Global.selected_char:
		if not Global.selected_char.can_act():
			SignalBus.dialog_show_message.emit("You currently cannot act.")
			return
		var element = get_priority_element_on_tile(coords)
		if element == null:
			interact_move(Global.selected_char, coords)
		elif element is AreaCondition:
			interact_move(Global.selected_char, coords)
		elif element is Creature:
			if force_interact:
				Global.selected_char.perform_attack(coords)
			else:
				Global.selected_char.perform_attack(coords)
		elif element is Item:
			if force_interact:
				Global.selected_char.perform_attack(coords)
			else:
				interact_grab(Global.selected_char, element, coords)
		elif element is Prop:
			if force_interact:
				Global.selected_char.perform_attack(coords)
			else:
				interact_operate(Global.selected_char, element, coords)

func get_close_to_target(creature: Creature, target: Vector3i, distance: int) -> bool:
	var char_coords = creature.get_coords()
	if char_coords.z == target.z and WorldMath.is_in_range(char_coords, target, 1):
		pass
	else:
		var path = path_to_adjacency(char_coords, target, distance)
		if path:
			interact_move(creature, path[1])
			if Global.selected_char.get_coords() != path[-1]:
				return false
	return true

func interact_operate(creature: Creature, element: Prop, coords: Vector3i):
	if get_close_to_target(creature, coords, 1):
		creature.perform_operate(element)

func interact_grab(creature: Creature, element: Item, coords: Vector3i):
	if get_close_to_target(creature, coords, 1):
		creature.grab_item_from_coords(element, coords)

func _complex_interact():
	pass

func _on_world_select():
	var coords = get_tile_coords()
	select_creature_on_tile(coords.vec3)

func _on_world_interact():
	var coords = get_tile_coords_under_cursor()
	var layer_coords = Vector2i(coords.x, coords.y)
	if Global.selected_char:
		if layers[current_level]["occupied"].get(layer_coords):
			_interact_attack(coords)
		else:
			interact_move(Global.selected_char, coords)

func _interact_attack(coords: Vector3i):
	var layer_coords = Vector2i(coords.x, coords.y)
	var target: Creature
	for element in layers[coords.z]["contents"].get(layer_coords):
		if element is Creature:
			target = element
			break
	if not target:
		return
	Global.focus_char.perform_attack(target)

func calculate_ap_cost(cost: float, current_available_mp: float, mp_per_ap: float, total_mp: float) -> int:
	var mp_after = current_available_mp  # This is AFTER the move
	var mp_before = current_available_mp + cost  # Reconstruct BEFORE the move
	
	# If we haven't moved yet this turn (still at full MP), any move costs 1 AP
	if mp_before >= total_mp:
		# First move of the turn - costs 1 AP plus any additional boundaries crossed
		var consumed_after = total_mp - mp_after
		# How many full mp_per_ap chunks did we consume?
		var ap_consumed = ceili(consumed_after / mp_per_ap)
		return ap_consumed
	else:
		# Not the first move - only pay for crossing boundaries
		var consumed_before = total_mp - mp_before
		var consumed_after = total_mp - mp_after
		
		var ap_used_before = ceili(consumed_before / mp_per_ap)
		var ap_used_after = ceili(consumed_after / mp_per_ap)
		
		var ap_consumed = ap_used_after - ap_used_before
		return ap_consumed

func teleport(character: Creature, target: Vector3i):
	var origin = character.get_coords()
	var layer_origin = Vector2i(origin.x, origin.y)
	var layer_target = Vector2i(target.x, target.y)
	var path_map = layers[target.z]["path_map"]
	
	if not path_map.region.has_point(layer_target) or path_map.is_point_solid(layer_target) or layers[target.z]["occupied"].get(layer_target):
		print("Invalid target location.")
		return
	
	character.global_position = layers[target.z]["tile_map"].map_to_local(layer_origin)
	move_char_to_tile(character, origin, target)
	character.global_position = layers[target.z]["tile_map"].map_to_local(layer_target)
	character.mover.position = Vector2.ZERO # Very necessary because of position/global_position mismatch during real-time move
	
	character.mover._on_stop_all_movement()
	
	character.visible = (character.data.tile_z == current_level)
	SignalBus.update_ui_for_char.emit()
	selection_highlight.update_selection_highlight()
	SignalBus.sight_check.emit(target)

func interact_move(character: Creature, target: Vector3i):
	var origin = character.get_coords()
	var layer_origin = Vector2i(origin.x, origin.y)
	var layer_target = Vector2i(target.x, target.y)
	var path = null
	var cost: float = 0
	var path_map = layers[target.z]["path_map"]
	if not path_map.region.has_point(layer_target) or path_map.is_point_solid(layer_target) or layers[target.z]["occupied"].get(layer_target):
		print("Invalid target location.")
		return

	print("origin: %d/%d" % [origin.x, origin.y])
	print("goal: %d/%d" % [target.x, target.y])

	path_map.set_point_solid(layer_origin, false)
	if not character.data.player_controlled:
		path = get_multi_level_path_for_creature(character, target, false, true)
	else:
		path = get_multi_level_path_for_creature(character, target)
	if path.is_empty():
		print("No path found!")
		return
	cost = calculate_path_cost_3D_simple(path)
	
	if Global.crisis_manager.crisis_mode:
		var current_available_mp = character.get_stat("current_mp")
		if cost > current_available_mp:
			SignalBus.dialog_show_message.emit("You do not have enough movements points.")
			return
		else:
			character.consume_mp(cost)
		var max_ap = character.get_stat("max_ap")
		var mp_per_ap = character.get_stat("max_mp")
		var total_mp = mp_per_ap * max_ap
		
		current_available_mp = character.get_stat("current_mp")
		var ap_cost = calculate_ap_cost(cost, current_available_mp, mp_per_ap, total_mp)
		character.consume_ap(ap_cost, false)
		path_preview.get_char_data()
		move_char_along_path(character, path)
	else:
		character.mover.begin_path(path)
	character.visible = (character.data.tile_z == current_level)
	SignalBus.update_ui_for_char.emit()
	selection_highlight.update_selection_highlight()

func handle_tile_conditions(tile: Vector3i, creature: Creature):
	var layer_tile: Vector2i = Vector2i(tile.x, tile.y)
	if layers[tile.z]["contents"].has(layer_tile):
		for element in layers[tile.z]["contents"][layer_tile]:
			if element is AreaCondition and element.trigger == Enums.AreaConditionTrigger.ENTER:
				element.apply_to_entity(creature)

func flash_path(path: Array) -> void:
	for point in path:
		print("Tile (%d:%d:%d)" % [point[0], point[1], point[2]])
		if point[2] == current_level:
			var point_coords = Vector2i(point[0], point[1])
			flash_tile_overlay(point_coords)

func visualize_area(tiles: Array[Vector3i], rect_container: Array, line_container: Array, colour: Color = Color8(0, 255, 0, 255)) -> void:
	# Convert tiles array to a set for fast lookup
	var tile_set = {}
	for tile in tiles:
		tile_set[tile] = true
	
	for tile in tiles:
		var rect = ColorRect.new()
		rect.color = Color(colour, 0.3)
		rect.size = Vector2(Global.TILE_SIZE, Global.TILE_SIZE)
		var pos = tile_to_pixels(tile)
		@warning_ignore("integer_division")
		rect.position = Vector2(pos.x - Global.TILE_SIZE/2, pos.y - Global.TILE_SIZE/2)
		rect.z_index = 999
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(rect)
		rect_container.append(rect)
		
		# Draw border lines where there's no adjacent tile
		draw_tile_borders(tile, tile_set, pos, line_container, colour)

func draw_tile_borders(tile: Vector3i, tile_set: Dictionary, pixel_pos: Vector2, line_container: Array, colour) -> void:
	var directions = [
		{"offset": Vector3i(-1, 0, 0), "start": Vector2(0, 0), "end": Vector2(0, Global.TILE_SIZE)},  # LEFT
		{"offset": Vector3i(1, 0, 0), "start": Vector2(Global.TILE_SIZE, 0), "end": Vector2(Global.TILE_SIZE, Global.TILE_SIZE)},  # RIGHT
		{"offset": Vector3i(0, -1, 0), "start": Vector2(0, 0), "end": Vector2(Global.TILE_SIZE, 0)},  # UP (north)
		{"offset": Vector3i(0, 1, 0), "start": Vector2(0, Global.TILE_SIZE), "end": Vector2(Global.TILE_SIZE, Global.TILE_SIZE)}  # DOWN (south)
	]
	
	for dir in directions:
		var neighbor = tile + dir.offset
		
		# If neighbor is not in the tile set, draw border on this edge
		if not tile_set.has(neighbor):
			var line = Line2D.new()
			@warning_ignore("integer_division")
			var base_pos = Vector2(pixel_pos.x - Global.TILE_SIZE/2, pixel_pos.y - Global.TILE_SIZE/2)
			line.add_point(base_pos + dir.start)
			line.add_point(base_pos + dir.end)
			line.width = 0.5
			line.default_color = colour
			#line.default_color = Color8(0, 255, 0, 255)  # Bright opaque green
			line.z_index = 1000
			add_child(line)
			line_container.append(line)  # Store for cleanup (change array type if needed)

func clear_all_visualizations() -> void:
	clear_visualization(preview_visualized_rects, preview_visualized_lines)
	clear_visualization(committed_visualized_rects, committed_visualized_lines)

func clear_visualization(visualized_rects: Array, visualized_lines: Array) -> void:
	for rect in visualized_rects:
		rect.queue_free()
	visualized_rects.clear()
	for line in visualized_lines:
		line.queue_free()
	visualized_lines.clear()

func _on_world_ready():
	world_ready = true

func _on_world_quit():
	world_ready = true

#func _on_local_timeout():
	#SignalBus.local_turn_passed.emit()
#
#func _on_crisis_mode_started(_creature):
	#local_timer.paused = true
#
#func _on_crisis_mode_ended(_creature):
	#local_timer.paused = false

func time_effects_on_creatures(n):
	for creature in current_world.creatures:
		creature.decay_needs(n)
		if not creature.data.player_controlled:
			creature.ai_controller.localai.change_routine()

func _ready() -> void:
	map_state = MapState.new()
	spawner = Spawner.new()
	spawner.wm = self
	selection_highlight.update_selection_highlight()
	SignalBus.simple_interact.connect(_simple_interact_disambiguation)
	SignalBus.complex_interact.connect(_complex_interact)
	SignalBus.world_ready.connect(_on_world_ready)
	SignalBus.world_quit.connect(_on_world_quit)
	SignalBus.hour_change.connect(time_effects_on_creatures)
	path_preview = PathPreviewScene.instantiate()
	add_child(path_preview)
	add_child(hover_tile)
