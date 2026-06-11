extends Node

class_name InputManager

var wm = null
var cm = null

func BasicControls():
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()

	if Input.is_action_just_pressed("F12"):
		Global.toggle_pause()

	if Input.is_action_just_pressed("PageUp"):
		wm.change_level(1)
		if wm.current_world:
			for creature in wm.current_world.creatures:
				print("Creature: %s" % [creature.data.name])
				creature.visible = (creature.data.tile_z == wm.current_level)
		
	if Input.is_action_just_pressed("PageDown"):
		wm.change_level(-1)
		if wm.current_world:
			for creature in wm.current_world.creatures:
				creature.visible = (creature.data.tile_z == wm.current_level)

	if Input.is_action_just_pressed("F"):
		var coords = wm.get_tile_coords_under_cursor()
		var item = Library.get_item("wpn_bow")
		var item_instance = item.duplicate()
		wm.add_to_tile(item_instance, coords)
		wm.add_item_visual(coords)
		print("Item just added to tile.")

	if Input.is_action_just_pressed("G"):
		Global.state_manager.save_game_state()

	if Input.is_action_just_pressed("R"):
		var coords = wm.get_tile_coords()
		if wm.layers[wm.current_level]["contents"].has(coords.vec2):
			var contents_copy = wm.layers[wm.current_level]["contents"][coords.vec2].duplicate()
			for element in contents_copy:
				if element is Item:
					wm.remove_from_tile(element, coords.vec3)

	if Input.is_action_just_pressed("T"):
		if not wm.current_world:
			return
		var coords = wm.get_tile_coords_under_cursor()
		wm.spawn_character("res://saved/characters/Debug.tres", coords)
		
	if Input.is_action_just_pressed("Y"):
		if not wm.current_world:
			return
		var coords: Vector3i = wm.get_tile_coords_under_cursor()
		var data: String = "res://resources/creatures/data_bandit.tres"
		var routine: String = "res://resources/routines/bandit_routine.tres"
		wm.spawn_character(data, coords, routine)

	if Input.is_action_just_pressed("U"):
		var hovered_tile = Global.world_manager.get_hovered_tile()
		var layer_tile = Vector2i(hovered_tile.x, hovered_tile.y)
		var creature = wm.get_creature_at_pos(hovered_tile)
		SignalBus.dialog_show_message.emit("Tile: (%d, %d, %d)" % [hovered_tile.x, hovered_tile.y, hovered_tile.z])
		SignalBus.dialog_show_message.emit("Creature: %s" % [creature.data.name if creature else "None"])

		print("-= (%d:%d) =-" % [hovered_tile.x, hovered_tile.y])
		if wm.layers[hovered_tile.z]["contents"].has(layer_tile):
			print("Contents: ")
			for element in wm.layers[hovered_tile.z]["contents"][layer_tile]:
				if element is Item:
					print("	%s (item)" % element.name)
				elif element is Creature:
					print("	%s (creature)" % element.data.name)
				elif element is Prop:
					print("	%s (prop)" % element.id)
				elif element is AreaCondition:
					print("	%s (Condition)" % element.id)

		var pm: AStarGrid2D = wm.layers[wm.current_level]["path_map"]

		if not pm.is_in_boundsv(layer_tile):
			print("This tile is OUT OF BOUNDS (treated as solid)")
		elif pm.is_point_solid(layer_tile):
			print("This tile is SOLID!")
		else:
			print("This tile is free to move onto.")

	if Input.is_action_just_pressed("I"):
		if not Global.selected_char:
			return
		SignalBus.update_inventory.emit()
		Global.all_info_window.tabs.set_current_tab(1)
		Global.all_info_window.visible = not Global.all_info_window.visible
		#Global.inventory_window.visible = not Global.inventory_window.visible
		print("Toggling inventory.")

	if Input.is_action_just_pressed("C"):
		if not Global.selected_char:
			return
		SignalBus.update_character_info.emit()
		SignalBus.update_inventory.emit()
		var window = Global.all_info_window
		window.tabs.set_current_tab(0)
		if window.visible == false:
			window.visible = true
		else:
			window.visible = false

	if Input.is_action_just_pressed("O"):
		if not Global.selected_char:
			return
		var coords = wm.get_tile_coords_under_cursor()
		wm.teleport(Global.selected_char, coords)

	if Input.is_action_just_pressed("P"):
		if not Global.selected_char:
			return
		var coords = Global.selected_char.get_coords()
		var layer_coords = Vector2i(coords.x, coords.y)
		if wm.layers[coords.z]["contents"].has(layer_coords):
			var contents_copy = wm.layers[coords.z]["contents"][layer_coords].duplicate()
			for element in contents_copy:
				if element is Item:
					wm.remove_from_tile(element, coords)
					Global.selected_char.data.inventory.add_item(element)
					SignalBus.update_inventory.emit()
					SignalBus.dialog_show_message.emit("Picked up %s." % element.name)

	if Input.is_action_just_pressed("K"):
		var coords = wm.get_tile_coords_under_cursor()
		print("Tile: (%d, %d, %d)" % [coords.x, coords.y, coords.z])
		#var coords = wm.get_hovered_tile()
		wm.spawn_prop(Library.get_prop("wooden_crate"), coords)

	if Input.is_action_just_pressed("H"):
		print("creatures found in the world:")
		for creature in wm.current_world.creatures:
			print(creature.data.name)
		for creature_a in wm.current_world.creatures:
			if creature_a.data.name == "Bandit":
				for creature_b in wm.current_world.creatures:
					if creature_b.data.name == "Andimar":
						creature_a.data.relationships.hostile.append(creature_b)
			elif creature_a.data.name == "Andimar":
				for creature_b in wm.current_world.creatures:
					if creature_b.data.name == "Bandit":
						creature_a.data.relationships.hostile.append(creature_b)
		print("Relationships set!")

	if Input.is_action_just_pressed("L"):
		var map_delta = wm.get_map_delta(wm.current_world.id)
		for prop in map_delta.added_props:
			print("prop: %s (pos: %d, %d, %d)" % [prop.id, prop.pos.x, prop.pos.y, prop.pos.z])

	if Input.is_action_just_pressed("J"):
		var coords = wm.get_tile_coords_under_cursor()
		var layer_coords = Vector2i(coords.x, coords.y)
		for layer in wm.current_world.get_children():
			if layer.id == wm.current_level:
				layer.set_cell(layer_coords, 5, Vector2i(2, 11))
				var tile_data = layer.get_cell_tile_data(layer_coords)
				if tile_data and tile_data.get_custom_data("walkable") == false:
					wm.layers[coords.z]["path_map"].set_point_solid(layer_coords, true)
				else:
					wm.layers[coords.z]["path_map"].set_point_solid(layer_coords, false)
				SignalBus.dialog_show_message.emit("Tile changed.")
				return

	if Input.is_action_just_pressed("M"):
		if not Global.selected_char:
			return
		var character = Global.selected_char
		SignalBus.dialog_show_message.emit("Current AP: %s" % [character.data.current_ap])
		for modifier in character.data.activity_modifiers:
			SignalBus.dialog_show_message.emit("Modifier: %s" % [modifier.name])

	if Input.is_action_just_pressed("N"):
		var hovered_tile = Global.world_manager.get_hovered_tile()
		var targets = WorldMath.shape_burst_entities(hovered_tile, 6)
		SignalBus.dialog_show_message.emit("Targets found:")
		for target in targets:
			SignalBus.dialog_show_message.emit("	%s" % [target.data.name])

	if Input.is_action_just_pressed("E"):
		if not Global.selected_char:
			return
		var character = Global.selected_char
		character.rebuild_shader()
		SignalBus.dialog_show_message.emit("Shader for selected creature has been rebuilt!")

	if Input.is_action_just_pressed("B"):
		if not Global.selected_char:
			return
		var character = Global.selected_char
		SignalBus.dialog_show_message.emit("Activity modifiers active:")
		for mod in character.data.activity_modifiers:
			SignalBus.dialog_show_message.emit("Mod %s" % mod.name)
		#SignalBus.dialog_show_message.emit("Available MP: %d" % Global.selected_char.get_stat("current_mp"))

	if Input.is_action_just_pressed("X"):
		if not Global.selected_char:
			return
		var current_mp = Global.selected_char.get_stat("current_mp")
		SignalBus.dialog_show_message.emit("Current mp: %d" % current_mp)
		var current_ap = Global.selected_char.get_stat("current_ap")
		SignalBus.dialog_show_message.emit("Current ap: %d" % current_ap)

	if Input.is_action_just_pressed("V"):
		SignalBus.dialog_show_message.emit("Number of active creatures: %d" % Global.ai_manager.active_number)

	if Input.is_action_just_pressed("Backspace"):
		SignalBus.request_toggle_crisis.emit(Global.focus_char)

	if Input.is_action_just_pressed("Enter"):
			SignalBus.end_crisis_turn.emit()
			
	if Input.is_action_just_pressed("S"):
		if not Global.selected_char:
			return
		var window = Global.all_info_window
		window.tabs.set_current_tab(2)
		if window.visible == false:
			window.visible = true
		else:
			window.visible = false

#func CharControls():
	#if not Global.focus_char:
		#return
#
	#if Input.is_action_just_pressed("Z"):
		#try_move_char_rel(0, -1)
#
	#if Input.is_action_just_pressed("S"):
		#try_move_char_rel(0, 1)
#
	#if Input.is_action_just_pressed("Q"):
		#try_move_char_rel(-1, 0)
#
	#if Input.is_action_just_pressed("D"):
		#try_move_char_rel(1, 0)

func _ready():
	wm = Global.world_manager
	cm = Global.crisis_manager
