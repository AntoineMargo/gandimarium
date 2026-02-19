extends Node

class_name InputManager

var wm = null
var cm = null

func _unhandled_input(event: InputEvent) -> void:
	if Global.world_manager.current_world:
		if cm.activity_mode:
			cm.forward_unhandled_input(event)
		else:
			if event is InputEventMouseButton and event.pressed:
				match event.button_index:
					MOUSE_BUTTON_LEFT:
						if event.ctrl_pressed:
							SignalBus.simple_interact.emit(true)
						else:
							SignalBus.simple_interact.emit(false)
					MOUSE_BUTTON_RIGHT:
						SignalBus.complex_interact.emit()


#func _unhandled_input(event: InputEvent) -> void:
	#if Global.world_manager.current_world:
		#if cm.activity_mode:
			#cm.forward_unhandled_input(event)
		#else:
			#if event is InputEventMouseButton and event.pressed:
				#match event.button_index:
					#MOUSE_BUTTON_LEFT:
						#SignalBus.simple_interact.emit()
					#MOUSE_BUTTON_RIGHT:
						#SignalBus.complex_interact.emit()

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
		print("Global is a: ", Global)
		print("Global type: ", typeof(Global))
		print("Global class: ", Global.get_class())

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
		#wm.spawn_player()
		wm.spawn_character("res://resources/creatures/data_andimar.tres")
		
	if Input.is_action_just_pressed("Y"):
		if not wm.current_world:
			return
		#wm.spawn_enemy()
		wm.spawn_character("res://resources/creatures/data_bandit.tres")

	if Input.is_action_just_pressed("U"):
		var coords = wm.get_tile_coords()
		var tile_coords: Vector2i = coords.vec2

		print("Current location: (%d:%d)" % [tile_coords.x, tile_coords.y])

		if wm.layers[wm.current_level]["contents"].has(tile_coords):
			print("Contents: ")
			for element in wm.layers[wm.current_level]["contents"][tile_coords]:
				if element is Item:
					print("	%s" % element.name)
				if element is Node:
					print("	%s" % element.data.name)

		var pm: AStarGrid2D = wm.layers[wm.current_level]["path_map"]

		if not pm.is_in_boundsv(tile_coords):
			print("This tile is OUT OF BOUNDS (treated as solid)")
		elif pm.is_point_solid(tile_coords):
			print("This tile is SOLID!")
		else:
			print("This tile is free to move onto.")

	if Input.is_action_just_pressed("I"):
		if not Global.selected_char:
			return
		SignalBus.update_inventory.emit()
		Global.inventory_window.visible = not Global.inventory_window.visible
		print("Toggling inventory.")

	if Input.is_action_just_pressed("C"):
		if not Global.selected_char:
			return
		Global.selected_char.update_stats()
		SignalBus.update_character_info.emit()
		Global.character_window.visible = not Global.character_window.visible
		print("Toggling character info.")

	if Input.is_action_just_pressed("O"):
		if not Global.selected_char:
			return
		SignalBus.dialog_show_message.emit("Current spell rank: %d" % Global.selected_char.data.current_spell_rank)
		SignalBus.dialog_show_message.emit("Max spell rank: %d" % Global.selected_char.data.max_spell_rank)

		#var char_coords = Global.get_char_coords(Global.focus_char)
#
		#var reachable_tiles = Global.get_reachable_tiles_with_diagonals(Global.layers[Global.current_level]["path_map"], char_coords, 10)
		#if reachable_tiles:
			#Global.clear_reachable_tiles()
		#Global.show_reachable_tiles(reachable_tiles)
		#print("Showing reachable tiles.")

	if Input.is_action_just_pressed("P"):
		if not Global.selected_char:
			return
		var coords = wm.get_char_coords(Global.selected_char)
		if wm.layers[wm.current_level]["contents"].has(coords.vec2):
			var contents_copy = wm.layers[coords.vec3.z]["contents"][coords.vec2].duplicate()
			for element in contents_copy:
				if element is Item:
					wm.remove_from_tile(element, coords)
					Global.selected_char.get_inventory().append(element)
					SignalBus.update_inventory.emit()
					SignalBus.dialog_show_message.emit("Picked up %s." % element.name)
		

	if Input.is_action_just_pressed("K"):
		if not Global.selected_char:
			return
		print("focus char: ", Global.focus_char.data.name)
		print("selected char: ", Global.selected_char.data.name)
		SignalBus.dialog_show_message.emit("Selected: %s" % [Global.selected_char.data.name])
		SignalBus.dialog_show_message.emit("Focus: %s" % [Global.focus_char.data.name])

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

	if Input.is_action_just_pressed("M"):
		if Global.crisis_manager.crisis_mode:
			SignalBus.dialog_show_message.emit("Crisis mode: Active")
		else:
			SignalBus.dialog_show_message.emit("Crisis mode: Inactive")

	if Input.is_action_just_pressed("E"):
		if not Global.selected_char:
			return
		var c = Global.selected_char
		print("active category: ", c.data.equipment.get_active_attack_category())
		print("active set: ", c.data.get_active_set())
		print("active hand: ", c.data.get_active_hand())
		print("Set 1 left strike: ", c.data.equipment.strike_types[0][0])
		print("Set 1 right strike: ", c.data.equipment.strike_types[0][1])
		print("Set 2 left strike: ", c.data.equipment.strike_types[1][0])
		print("Set 2 right strike: ", c.data.equipment.strike_types[1][1])
		print("Current set left throw: ", c.data.equipment.throw_types[0])
		print("Current set right throw: ", c.data.equipment.throw_types[1])
		var weapons = c.data.get_active_weapons()
		if weapons[0]:
			print("Main weapon: ",  weapons[0].name)
		else:
			print("Main weapon: Empty")
		if weapons[1]:
			print("Offhand weapon: ",  weapons[1].name)
		else:
			print("Offhand weapon: Empty")

	if Input.is_action_just_pressed("B"):
		var character = Global.selected_char
		SignalBus.dialog_show_message.emit("Activity modifiers active:")
		for mod in character.data.activity_modifiers:
			SignalBus.dialog_show_message.emit("Mod %s" % mod.name)
		#SignalBus.dialog_show_message.emit("Available MP: %d" % Global.selected_char.get_stat("current_mp"))

	if Input.is_action_just_pressed("V"):
		SignalBus.dialog_show_message.emit("Number of active creatures: %d" % Global.ai_manager.active_number)

	if Input.is_action_just_pressed("Backspace"):
		SignalBus.request_toggle_crisis.emit(Global.focus_char)

	if Input.is_action_just_pressed("Enter"):
			SignalBus.end_crisis_turn.emit()

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
