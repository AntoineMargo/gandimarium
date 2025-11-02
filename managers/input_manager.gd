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
						SignalBus.world_select.emit()
					MOUSE_BUTTON_RIGHT:
						if Global.selected_char:
							SignalBus.world_interact.emit()

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
				creature.visible = (creature.data.map_layer_id == wm.current_level)
		
	if Input.is_action_just_pressed("PageDown"):
		wm.change_level(-1)
		if wm.current_world:
			for creature in wm.current_world.creatures:
				creature.visible = (creature.data.map_layer_id == wm.current_level)

	if Input.is_action_just_pressed("F"):
		var coords = wm.get_tile_coords()
		var longspear := preload("res://items/weapons/wpn_longsword.tres")
		#var longspear_instance = longspear.duplicate()
		wm.add_to_tile(longspear, coords)
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
		wm.spawn_player()
		
	if Input.is_action_just_pressed("Y"):
		if not wm.current_world:
			return
		wm.spawn_enemy()

	if Input.is_action_just_pressed("U"):
		var coords = wm.get_tile_coords()
		print("Current location: (%d:%d)" % [coords.vec2.x, coords.vec2.y])
		if wm.layers[wm.current_level]["contents"].has(coords.vec2):
			print("Contents: ")
			for element in wm.layers[wm.current_level]["contents"][coords.vec2]:
				if element is Item:
					print("	%s" % element.name)
				if element is Node:
					print("	%s" % element.data.name)

	if Input.is_action_just_pressed("I"):
		if not Global.selected_char:
			return
		SignalBus.update_inventory.emit()
		Global.inventory_window.visible = not Global.inventory_window.visible
		print("Toggling inventory.")

	#if Input.is_action_just_pressed("O"):
		#if not Global.focus_char:
			#return
#
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
					Global.selected_char.data.inventory.append(element)
					SignalBus.update_inventory.emit()
					Global.ui_log.text += "\nPicked up %s." % element.name
					Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

	if Input.is_action_just_pressed("K"):
		if not Global.selected_char:
			return
		print("Inventory:")
		for element in Global.selected_char.data.inventory:
			print("	", element)

	if Input.is_action_just_pressed("H"):
		Global.ui_log.text += "\nTest message!"
		Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

	if Input.is_action_just_pressed("L"):
		Global.inventory_window.print_tree_pretty()
		#print_tree_pretty()
		
	if Input.is_action_just_pressed("M"):
		for creature in wm.current_world.creatures:
			print(creature.data.name)

	if Input.is_action_just_pressed("E"):
		Global.ui_log.text += "\nActivity n°1 on character: %s" % Global.selected_char.data.activities[0].name
		Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

	if Input.is_action_just_pressed("Backspace"):
		SignalBus.toggle_crisis_button.emit()

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
