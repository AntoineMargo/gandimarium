extends Node

class_name WorldManager

var layers: Dictionary = {}
var layer_links: Dictionary = {}
var current_tile_map_layer: TileMapLayer = null
var current_level : int = 0
var current_world: Node = null

var target_highlights = []

@onready var selection_highlight = load("res://interface/selection_highlight.tscn").instantiate()


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
			astar.cell_size = Vector2(40, 40)
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
	var char = Global.selected_char.char_data
	for coords in char.reachable_tiles:
		if coords.z != current_level:
			continue
		var coords_2d = Vector2i(coords[0], coords[1])
		var painted_scene = preload("res://interface/painted_tile_effect.tscn")
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
	if not Global.selected_char:
		return
	var char = Global.selected_char
	var size = char.char_data.movement_points_left
	var coords = get_char_coords(char)
	#char.char_data.reachable_tiles = get_reachable_tiles_with_diagonals(layers[coords.vec3.z]["path_map"], coords.vec2, size)
	char.char_data.reachable_tiles = get_reachable_tiles_3D_with_diagonals(coords.vec3, size)

func _on_refresh_reachable_tiles():
	clear_reachable_tiles()
	build_reachable_tiles()
	show_reachable_tiles()

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


func _on_world_select():
	var coords = get_tile_coords()
	if layers[current_level]["contents"].has(coords.vec2):
		for element in layers[current_level]["contents"][coords.vec2]:
			if element is Creature:
				Global.selected_char = element
				selection_highlight.update_selection_highlight()
				SignalBus.update_inventory.emit()
				SignalBus.update_ui_for_char.emit()
				SignalBus.refresh_reachable_tiles.emit()
				print("Selected character: ", element.char_data.name)
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

	SignalBus.weapon_attack.emit(target)

func _interact_move(t_coords):
	var char = Global.selected_char
	var o_coords = get_char_coords(char)
	var path = null
	var cost: float = 0
	var path_map = layers[t_coords.vec3.z]["path_map"]
	if not path_map.region.has_point(t_coords.vec2) or path_map.is_point_solid(t_coords.vec2) or layers[t_coords.vec3.z]["occupied"].get(t_coords.vec2):
		print("Invalid target location.")
		return

	path = get_multi_level_path(o_coords.vec3, t_coords.vec3)

	if path.is_empty():
		print("No path found!")
		return
	
	cost = calculate_path_cost_3D(path)
	print("Path length: ", path.size() - 1, " steps.")
	print("Path cost: ", cost)
	if Global.crisis_manager.crisis_mode:
		if cost > char.char_data.movement_points_left:
			SignalBus.dialog_show_message.emit("You do not have enough movements points.")
			return
		else:
			char.char_data.movement_points_left -= cost
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

func calculate_path_cost_3D(path: Array[Vector3i], tile_size: int = 40) -> float:
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

		print("Step ", i, ": ", prev, " → ", curr, " | delta: ", delta, " | diagonal: ", is_diagonal, " | cost: ", step_cost)

		total_cost += step_cost
	
	return total_cost

func _try_move_char_abs(target):
	if not Global.selected_char:
		return
	var char = Global.selected_char
	var origin = get_char_coords(char)

	layers[origin.vec3.z]["occupied"][origin.vec2] = false
	layers[origin.vec3.z]["path_map"].set_point_solid(origin.vec2, false)
	remove_from_tile(char, origin)
	
	char.char_data.tile_x = target.vec3.x
	char.char_data.tile_y = target.vec3.y
	char.char_data.map_layer_id = target.vec3.z
	#char.position = Global.current_tile_map_layer.map_to_local(target_2d)
	#Global.selected_char.position = Global.current_tile_map_layer.map_to_local(target_2d)
	char.position = layers[target.vec3.z]["tile_map"].map_to_local(target.vec2)

	layers[target.vec3.z]["occupied"][target.vec2] = true
	add_to_tile(char, target)
	layers[target.vec3.z]["path_map"].set_point_solid(target.vec2, true)

func get_multi_level_path(start: Vector3i, goal: Vector3i) -> Array[Vector3i]:
	var path_array = []
	var visited: Dictionary = {}
	var success = _find_recursive_path(start, goal, path_array, visited)
	if not success:
		return []

	# Flatten the path segments into a single array
	var full_path: Array[Vector3i] = []
	for segment in path_array:
		full_path.append_array(segment)
	return full_path

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

func get_char_coords(character) -> Dictionary:
	var pos_3d = Vector3i(
	character.char_data.tile_x,
	character.char_data.tile_y,
	character.char_data.map_layer_id)
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
	var flash_scene = preload("res://interface/flash_tile_effect.tscn")
	var flash_instance = flash_scene.instantiate()
	
	var tilemap = layers[current_level]["tile_map"]
	var world_pos = tilemap.map_to_local(tile_pos)
	flash_instance.position = world_pos
	
	tilemap.add_child(flash_instance)
	flash_instance.get_node("AnimationPlayer").play("flash")
	
func update_creatures_visibility():
	if current_world:
		for creature in current_world.creatures:
			creature.visible = (creature.char_data.map_layer_id == current_level)

func spawn_test_character():
	if current_world == null:
		print("No current world.")
		return
	var my_char = Character.new()
	my_char.name = "Andimar"
	my_char.level = 12
	my_char.acuity = 7
	my_char.brawn = 6
	my_char.dexterity = 7
	my_char.will = 12
	#my_char.tile_x = 10
	#my_char.tile_y = 10
	my_char.map_id = current_world.id
	my_char.map_layer_id = current_level
	
	my_char.initialise()
	
	var longsword := preload("res://items/weapons/wpn_longsword.tres")
	my_char.inventory.append(longsword)
	var longspear := preload("res://items/weapons/wpn_longspear.tres")
	my_char.inventory.append(longspear)
	var med_shield := preload("res://items/weapons/wpn_medium_shield.tres")
	my_char.inventory.append(med_shield)
	var light_armour := preload("res://items/armours/ar_light.tres")
	my_char.inventory.append(light_armour)
	var heavy_armour := preload("res://items/armours/ar_heavy.tres")
	my_char.inventory.append(heavy_armour)
	var light_shield := preload("res://items/weapons/wpn_light_shield.tres")
	my_char.inventory.append(light_shield)
	var heavy_shield := preload("res://items/weapons/wpn_large_shield.tres")
	my_char.inventory.append(heavy_shield)
	var mace := preload("res://items/weapons/wpn_mace.tres")
	my_char.inventory.append(mace)
	var poleaxe := preload("res://items/weapons/wpn_poleaxe.tres")
	my_char.inventory.append(poleaxe)
	var warhammer := preload("res://items/weapons/wpn_warhammer.tres")
	my_char.inventory.append(warhammer)
	var partisan := preload("res://items/weapons/wpn_partisan.tres")
	my_char.inventory.append(partisan)
	var battleaxe := preload("res://items/weapons/wpn_battle_axe.tres")
	my_char.inventory.append(battleaxe)
	var dagger := preload("res://items/weapons/wpn_dagger.tres")
	my_char.inventory.append(dagger)
	var falchion := preload("res://items/weapons/wpn_falchion.tres")
	my_char.inventory.append(falchion)
	var shortsword := preload("res://items/weapons/wpn_shortsword.tres")
	my_char.inventory.append(shortsword)
	var quarterstaff := preload("res://items/weapons/wpn_quarterstaff.tres")
	my_char.inventory.append(quarterstaff)
	var greatsword := preload("res://items/weapons/wpn_greatsword.tres")
	my_char.inventory.append(greatsword)
	var great_axe := preload("res://items/weapons/wpn_great_axe.tres")
	my_char.inventory.append(great_axe)
	var saber := preload("res://items/weapons/wpn_saber.tres")
	my_char.inventory.append(saber)
	var bow := preload("res://items/weapons/wpn_bow.tres")
	my_char.inventory.append(bow)
	#var placeholder := preload()
	#my_char.inventory.append(placeholder)

	var move = preload("res://activities/activities/move.tres")
	var aura_damage = preload("res://activities/activities/aura_damage.tres")
	var firebolt = preload("res://activities/activities/firebolt.tres")
	var firebolts = preload("res://activities/activities/firebolts.tres")
	my_char.add_activity(move)
	my_char.add_activity(aura_damage)
	my_char.add_activity(firebolt)
	my_char.add_activity(firebolts)

	var firebolt_spell = preload("res://abilities/spells/firebolt.tres")
	my_char.add_ready_spell(firebolt_spell)
	
	var degrade_defences_spell = preload("res://abilities/spells/degrade_defences.tres")
	my_char.add_ready_spell(degrade_defences_spell)
	
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)
	#my_char.add_ready_spell(firebolt_spell)

	var char_scene = preload("res://creatures/creature.tscn")
	var char_instance = char_scene.instantiate()
	char_instance.char_data = my_char

	var tile_coords = get_tile_coords()
	var tile_data = current_tile_map_layer.get_cell_tile_data(tile_coords.vec2)
	if not tile_data.get_custom_data("walkable") or layers[current_level]["occupied"].get(tile_coords.vec2, false):
		print("Cannot spawn character on this tile!")
		return
	my_char.tile_x = tile_coords.vec2.x
	my_char.tile_y = tile_coords.vec2.y
	char_instance.position = layers[tile_coords.vec3.z]["tile_map"].map_to_local(tile_coords.vec2)
	current_world.add_child(char_instance)
	current_world.register_creature(char_instance)
	layers[current_level]["occupied"][tile_coords.vec2] = true
	my_char.map_id = "world"
	add_to_tile(char_instance, tile_coords)
	layers[current_level]["path_map"].set_point_solid(tile_coords.vec2, true)
	selection_highlight.update_selection_highlight()
	my_char.make_active_set(1)
	#selected_char = char_instance

#func is_tile_walkable(tilemap: TileMap, world_pos: Vector2) -> bool:
	#var coords = tilemap.local_to_map(world_pos)
	#var data = tilemap.get_cell_tile_data(0, coords)
	#return data != null and data.get_custom_data("walkable") == true

func _ready() -> void:
	selection_highlight.update_selection_highlight()
	SignalBus.world_select.connect(_on_world_select)
	SignalBus.world_interact.connect(_on_world_interact)
	SignalBus.refresh_reachable_tiles.connect(_on_refresh_reachable_tiles)
