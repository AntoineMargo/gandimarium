extends Node
class_name UIManager

const MAX_ACTIVITIES: int = 40
const COLUMNS: int  = 10

enum ItemsList {
	INVENTORY,
	CONTAINER
	}

var ui_node: Node = null

var drag_in_progress: bool = false
var drag_was_dropped: bool = true
var last_dragged_item: Item = null
var window_dragged_from: ItemsList = ItemsList.INVENTORY

var full_pip = preload("res://art/interface/base/pip.png")
var empty_pip = preload("res://art/interface/base/empty_pip.png")
var activity_button = preload("res://interface/bottom_bar/ActivityButton.tscn")
var spell_button = preload("res://interface/bottom_bar/spell_button.tscn")
var concentration_slot = preload("res://interface/bottom_bar/concentration_slot.tscn")

## Basic configuration of interface nodes on game startup
func set_ui_node(node: Node):
	ui_node = node
	
	var crisis_mode = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/CrisisModeButton")
	var end_turn = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/EndTurnButton")

	var set_toggler = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/CheckButton")

	var w1 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/Weapon1")
	var w2 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/Weapon2")

	var w1_slash = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/W1_AttackType1")
	var w1_pierce = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/W1_AttackType2")
	var w1_crush = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/W1_AttackType3")

	var w2_slash = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/W2_AttackType1")
	var w2_pierce = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/W2_AttackType2")
	var w2_crush = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/W2_AttackType3")

	var c1 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/Strike")
	var c2 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/Shoot")
	var c3 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/Throw")

	var slider = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/SpellRankSlider")

	#var activity_button_container = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/ActivitiesContainer/ActivitiesLine1")
	#for i in activity_button_container.get_child_count():
		#var button = activity_button_container.get_child(i)
		#button.connect("pressed", Callable(self, "_on_activity_button_pressed").bind(button))

	if crisis_mode:
		crisis_mode.connect("toggled", Callable(self, "on_crisis_mode_toggled"))

	if end_turn:
		end_turn.connect("pressed", Callable(self, "on_end_turn_pressed"))

	if set_toggler:
		set_toggler.connect("toggled", Callable(self, "on_weapon_set_toggled"))

	if c1 and c2 and c3:
		c1.connect("toggled", Callable(self, "on_category_button_toggled").bind(0))
		c2.connect("toggled", Callable(self, "on_category_button_toggled").bind(1))
		c3.connect("toggled", Callable(self, "on_category_button_toggled").bind(2))

	if w1 and w2:
		w1.connect("toggled", Callable(self, "on_weapon_button_toggled").bind(0))
		w2.connect("toggled", Callable(self, "on_weapon_button_toggled").bind(1))
	else:
		push_error("Could not connect weapon button signals.")

	if w1_slash and w1_pierce and w1_crush:
		w1_slash.connect("toggled", Callable(self, "on_attack1_button_toggled").bind(0))
		w1_pierce.connect("toggled", Callable(self, "on_attack1_button_toggled").bind(1))
		w1_crush.connect("toggled", Callable(self, "on_attack1_button_toggled").bind(2))
	else:
		push_error("Could not connect left hand attack button signals.")

	if w2_slash and w2_pierce and w2_crush:
		w2_slash.connect("toggled", Callable(self, "on_attack2_button_toggled").bind(0))
		w2_pierce.connect("toggled", Callable(self, "on_attack2_button_toggled").bind(1))
		w2_crush.connect("toggled", Callable(self, "on_attack2_button_toggled").bind(2))
	else:
		push_error("Could not connect right hand attack button signals.")
	
	if slider:
		slider.value_changed.connect(_on_slider_value_changed)

@warning_ignore("unused_parameter")
func on_crisis_mode_toggled(button_pressed: bool) -> void:
	SignalBus.request_toggle_crisis.emit(Global.focus_char)

func on_end_turn_pressed() -> void:
	SignalBus.end_player_turn.emit()

func on_attack1_button_toggled(button_pressed: bool, attack_type: int) -> void:
	if not button_pressed:
		return
	if not Global.selected_char:
		return
	var character = Global.selected_char
	var category = character.data.equipment.active_category
	var weapons = character.get_weapons()
	var left_weapon = weapons[0]
	
	if category == 0:
		left_weapon.selected_attacks[Enums.AttackCategory.STRIKE] = attack_type
	elif category == 1:
		left_weapon.selected_attacks[Enums.AttackCategory.SHOOT] = attack_type
	elif category == 2:
		left_weapon.selected_attacks[Enums.AttackCategory.THROW] = attack_type
	print("Active attack type changed.")

func on_attack2_button_toggled(button_pressed: bool, attack_type: int) -> void:
	if not button_pressed:
		return
	if not Global.selected_char:
		return
	var character = Global.selected_char
	var category = character.data.equipment.active_category
	var weapons = character.get_weapons()
	var right_weapon = weapons[1]
	
	if category == 0:
		right_weapon.selected_attacks[Enums.AttackCategory.STRIKE] = attack_type
	elif category == 1:
		right_weapon.selected_attacks[Enums.AttackCategory.SHOOT] = attack_type
	elif category == 2:
		right_weapon.selected_attacks[Enums.AttackCategory.THROW] = attack_type
	print("Active attack type changed.")

func on_category_button_toggled(button_pressed: bool, category) -> void:
	if not button_pressed:
		return
	var character = Global.selected_char
	if not character:
		return

	character.data.equipment.active_category = category
	print("Active category changed.")
	update_active_attack_buttons()

func on_weapon_button_toggled(button_pressed: bool, hand: int) -> void:
	if not button_pressed:
		return
	if Global.selected_char:
		Global.selected_char.set_active_hand(hand)
		print("Active hand changed.")

func on_weapon_set_toggled(button_pressed: bool) -> void:
	if Global.selected_char:
		if Global.selected_char.get_active_set() == 0:
			Global.selected_char.set_active_set(1)
		else:
			Global.selected_char.set_active_set(0)
		update_ui_for_char()

func update_active_attack_buttons():
	if ui_node == null or Global.selected_char == null:
		return

	var character = Global.selected_char
	var weapons = character.get_weapons()
	if weapons.size() < 2:
		return

	var left_weapon: Item = weapons[0]
	var right_weapon: Item = weapons[1]

	var category: Enums.AttackCategory = character.data.equipment.active_category

	var w1_buttons = [
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/W1_AttackType1"),
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/W1_AttackType2"),
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/W1_AttackType3")
	]

	var w2_buttons = [
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/W2_AttackType1"),
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/W2_AttackType2"),
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/W2_AttackType3")
	]

	_update_weapon_buttons(left_weapon, w1_buttons, category)
	_update_weapon_buttons(right_weapon, w2_buttons, category)

	# ----- Left weapon buttons -----

	for button in w1_buttons:
		button.disabled = true
	
	if left_weapon:
		var attack_types = null
		if category == 0:
			if left_weapon.strike:
				attack_types = left_weapon.strike.attack_types
			else:
				attack_types = []
		elif category == 1:
			if left_weapon.shoot:
				attack_types = left_weapon.shoot.attack_types
			else:
				attack_types = []
		elif category == 2:
			if left_weapon.throw:
				attack_types = left_weapon.throw.attack_types
			else:
				attack_types = []

		for type in attack_types:
			if type.id == 0:
				w1_buttons[0].disabled  = false
			elif type.id == 1:
				w1_buttons[1].disabled  = false
			elif type.id == 2:
				w1_buttons[2].disabled  = false

	# ----- Right weapon buttons -----
	
	for button in w2_buttons:
		button.disabled = true
	
	if right_weapon:
		var attack_types = null
		if category == 0:
			if right_weapon.strike:
				attack_types = right_weapon.strike.attack_types
			else:
				attack_types = []
		elif category == 1:
			if right_weapon.shoot:
				attack_types = right_weapon.shoot.attack_types
			else:
				attack_types = []
		elif category == 2:
			if right_weapon.throw:
				attack_types = right_weapon.throw.attack_types
			else:
				attack_types = []

		for type in attack_types:
			if type.id == 0:
				w2_buttons[0].disabled  = false
			elif type.id == 1:
				w2_buttons[1].disabled  = false
			elif type.id == 2:
				w2_buttons[2].disabled  = false

func _update_weapon_buttons(weapon: Item, buttons: Array, category: Enums.AttackCategory):
	if weapon == null:
		return

	var attack = weapon.selected_attacks.get(category)
	if attack == null:
		return

	for i in range(3):
		if buttons[i]:
			buttons[i].button_pressed = attack == i


func update_active_category_buttons():
	if ui_node == null or Global.selected_char == null:
		return
	
	var character = Global.selected_char
	if character == null:
		return
	var active_category = character.data.equipment.active_category

	var c1 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/Strike")
	var c2 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/Shoot")
	var c3 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/WeaponSetsContainer/Throw")

	if c1 and c2 and c3:
		c1.button_pressed = active_category == 0
		c2.button_pressed = active_category == 1
		c3.button_pressed = active_category == 2

func update_weapon_buttons():
	if ui_node == null or Global.selected_char == null:
		return
	
	var character = Global.selected_char
	if character == null:
		return

	var w1 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/Weapon1")
	var w2 = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/Weapon2")

	if w1 and w2:
		w1.button_pressed = character.data.equipment.active_hand == 0
		w2.button_pressed = character.data.equipment.active_hand == 1

func update_weapon_buttons_text():
	if ui_node == null:
		print("UI node not set!")
		return
	
	var item = null

	var character = Global.selected_char
	if !character:
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/Weapon1").text = "None"
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/Weapon2").text = "None"
		return

	var default_item = character.data.equipment.get_item_in_slot(Enums.EquipmentSlot.HAND_DEFAULT)

	item = character.data.equipment.get_item_in_slot(Enums.EquipmentSlot.HAND_LEFT)
	if item:
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/Weapon1").text = item.name
	else:
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon1Container/Weapon1").text = default_item.name
	item = character.data.equipment.get_item_in_slot(Enums.EquipmentSlot.HAND_RIGHT)
	if item:
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/Weapon2").text = item.name
	else:
		ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Weapon2Container/Weapon2").text = default_item.name

func _on_update_character_info() -> void:
	#Global.character_window.character = Global.selected_char
	Global.character_window.update(Global.selected_char)

func _on_update_inventory_window() -> void:
	var character = Global.selected_char
	for child in Global.items_list.get_children():
		child.queue_free()
	if Global.items_list == null:
		print("ItemsList node not found!")
		return
	if Global.selected_char == null:
		print("No character selected.")
		return
	var items = character.get_inventory()
	for i in range(items.size()):
		var element = preload("res://interface/inventory_window/inventory_element.tscn").instantiate()
		element.items_interface = Enums.ItemsList.INVENTORY
		element.index = i
		element.item = items[i]
		element.initialize()
		Global.items_list.add_child(element)

	var equipment_label_paths := {
		Enums.EquipmentSlot.HELM: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/HelmItem",
		Enums.EquipmentSlot.CAPE: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/CapeItem",
		Enums.EquipmentSlot.ARMOUR: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/ArmourItem",
		Enums.EquipmentSlot.TOP: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/TopItem",
		Enums.EquipmentSlot.BELT: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/BeltItem",
		Enums.EquipmentSlot.BOTTOM: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/BottomItem",
		Enums.EquipmentSlot.GAUNTLETS: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/GauntletsItem",
		Enums.EquipmentSlot.SHOES: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/ShoesItem",
		Enums.EquipmentSlot.NECKLACE: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/NecklaceItem",
		Enums.EquipmentSlot.BRACER_LEFT: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/LeftBracerItem",
		Enums.EquipmentSlot.BRACER_RIGHT: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/RightBracerItem",
		#Enums.EquipmentSlot.RING1: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/Ring1SpaceItem",
		#Enums.EquipmentSlot.RING2: "Inventory/MainVBox/SeparHBox/VBoxContainer/GridContainer/Ring2SpaceItem",
		Enums.EquipmentSlot.HAND_LEFT: "Inventory/MainVBox/SeparHBox/VBoxContainer/WeaponSet/WeaponSetSpace/LeftWeaponItem",
		Enums.EquipmentSlot.HAND_RIGHT: "Inventory/MainVBox/SeparHBox/VBoxContainer/WeaponSet/WeaponSetSpace/RightWeaponItem",
		#Enums.EquipmentSlot.HAND_LEFT: "Inventory/MainVBox/SeparHBox/VBoxContainer/WeaponSet2/WeaponSet2Space/WeaponSet2SpaceItemLeft",
		#Enums.EquipmentSlot.HAND_RIGHT: "Inventory/MainVBox/SeparHBox/VBoxContainer/WeaponSet2/WeaponSet2Space/WeaponSet2SpaceItemRight"
	}
	for slot in equipment_label_paths.keys():
		var path = equipment_label_paths[slot]
		var label_node = Global.inventory_window.get_node(path)
		if label_node and label_node is Label:
			var item = null
			item = character.data.equipment.get_item_in_slot(slot)
			if item:
				label_node.text = item.name
			else:
				label_node.text = "Empty"
		else:
			print("Label node not found at:", path)

func _on_drop_item_on_tile(selected_char):
	var wm = Global.world_manager
	var coords = selected_char.get_coords()
	wm.add_to_tile(last_dragged_item, coords)
	wm.add_item_visual(coords)
	print("Item just added to tile.")

func drag_fail_restore():
	if drag_in_progress and Input.is_action_just_released("mouse_left"):
		if last_dragged_item and not drag_was_dropped:

			var mouse_over_control = get_viewport().gui_get_hovered_control()
			print("UI element under cursor:", mouse_over_control)

			if mouse_over_control == null:
				print("Dropping item on ground.")
				SignalBus.drop_item_on_tile.emit(Global.selected_char, last_dragged_item)
			elif mouse_over_control != null and mouse_over_control.name == "UI":
				print("Dropping item on ground.")
				SignalBus.drop_item_on_tile.emit(Global.selected_char, last_dragged_item)
			else:
				print("Drag failed — restoring item.")
				if window_dragged_from == ItemsList.INVENTORY:
					Global.selected_char.data.inventory.add_item(last_dragged_item)
					SignalBus.update_inventory.emit()
				elif window_dragged_from == ItemsList.CONTAINER:
					Global.container_window.current_container.inventory.add_item(last_dragged_item)
					SignalBus.update_container.emit()

		drag_in_progress = false
		drag_was_dropped = true
		last_dragged_item = null

func update_action_pips():
	if Global.selected_char == null:
		return
	var character = Global.selected_char
	var max_ap = character.get_stat("max_ap")
	var current_ap = character.get_stat("current_ap")
	var container = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/ActionPoints")
	
	for i in container.get_child_count():
		var pip = container.get_child(i)
		if max_ap < i + 1:
			pip.visible = false
		else:
			pip.visible = true
			
	for i in range(max_ap):
		var pip = container.get_child(i)
		if i < current_ap:
			pip.modulate = Color(1, 1, 1, 1)
		else:
			pip.modulate = Color(0.5, 0.5, 0.5, 0.7)

func update_activity_buttons():
	var char = Global.selected_char
	var activities = Global.selected_char.data.activities
	
	var node_grid = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Activities")

	for child in node_grid.get_children():
		child.queue_free()

	var count = min(activities.size(), MAX_ACTIVITIES)
	for i in count:
		if activities[i].is_invisible == false:
			_create_activity_button(activities[i], node_grid)

func _set_button_active(button: TextureButton, active: bool) -> void:
	var icon := button.get_node("Icon") as TextureRect
	if not icon:
		return

	var mat = icon.material as ShaderMaterial
	if not mat:
		return

	mat.set_shader_parameter("outline_thickness", 2 if active else 0)

func _create_activity_button(activity, node_grid):
	var button = activity_button.instantiate() as TextureButton
	var icon = button.get_node("Icon") as TextureRect
	icon.texture = load(activity.icon)

	button.set_meta("activity", activity)
	node_grid.add_child(button)

	var character = Global.selected_char

	if activity.builds_condition and activity.condition_id == "":
		push_error("Activity %s builds condition but has no condition_id" % activity.name)

	if activity.builds_condition:
		button.toggle_mode = true

		var active = character.has_condition(activity.condition_id)

		button.set_pressed_no_signal(active)
		_set_button_active(button, active)

		button.toggled.connect(
			Callable(self, "_on_activity_button_toggled").bind(button)
		)
	else:
		button.pressed.connect(
			Callable(self, "_on_activity_button_pressed").bind(button)
		)


func update_spell_list():
	var character = Global.selected_char
	var spell_list = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/ScrollContainer/SpellList")
	var scroll_container = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/ScrollContainer")
	var separator = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/VSeparator3")
	var slider = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/SpellRankSlider")

	for child in spell_list.get_children():
		child.queue_free()

	if character.data.spells_ready.is_empty():
		spell_list.visible = false
		scroll_container.visible = false
		separator.visible = false
		slider.visible = false
		return
	spell_list.visible = true
	scroll_container.visible = true
	separator.visible = true
	slider.visible = true
	
	slider.max_value = character.get_stat("max_spell_rank")
	slider.value = character.get_stat("current_spell_rank")
	for spell in character.data.spells_ready:
		var spell_button = spell_button.instantiate()
		spell_button.spell = spell
		spell_list.add_child(spell_button)
		#spell_button.connect("pressed", Callable(self, "_on_spell_button_pressed").bind(spell_button))
		#spell_button.pressed.connect(update_concentration_slots.bind(spell))

func update_concentration_slots():
	var character = Global.selected_char
	var container = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/Concentrations")
	for child in container.get_children():
		child.queue_free()

	for i in range(character.get_stat("will")):
		var slot = concentration_slot.instantiate()
		if i < character.data.concentrations.size():
			var concentration = character.data.concentrations[i]
			slot.setup(concentration)
		else:
			slot.setup(null) # Empty slot
		container.add_child(slot)

func update_char_info():
	var character = Global.selected_char

	var hp_bar = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/HP_bar")
	var hp_label = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/HP_bar/HP_Label")
	
	var pp_bar = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/PP_bar_wrapper/PP_bar")
	var pp_bar_proj = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/PP_bar_wrapper/PP_bar_preview")
	var pp_label = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/PP_bar_wrapper/PP_Label")
	
	var ep_bar = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/EP_bar")
	var ep_label = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/EP_bar/EP_Label")

	hp_bar.max_value = character.get_stat("max_hp")
	hp_bar.value     = character.get_stat("current_hp")
	hp_label.text    = "%d/%d" % [
		character.get_stat("current_hp"),
		character.get_stat("max_hp")
	]

	pp_bar.max_value = character.get_stat("max_pp")
	pp_bar.value     = character.get_stat("current_pp")
	pp_bar_proj.max_value = character.get_stat("max_pp")
	
	if character.data.casting_table:
		var current_level_table = character.data.casting_table.cost_table[character.get_stat("level") - 1]
		var current_spell_cost = current_level_table.spell_costs[character.data.current_spell_rank]
		pp_bar_proj.value = character.get_stat("current_pp") - current_spell_cost
	else:
		pp_bar_proj.value     = character.get_stat("current_pp")
	
	pp_label.text    = "%d/%d" % [
		character.get_stat("current_pp"),
		character.get_stat("max_pp")
	]

	ep_bar.max_value = character.get_stat("max_ep")
	ep_bar.value     = character.get_stat("current_ep")
	ep_label.text    = "%d/%d" % [
		character.get_stat("current_ep"),
		character.get_stat("max_ep")
	]

func update_ui_for_char():
	print("===update_ui_for_char called===")
	if Global.selected_char == null or Global.selected_char != Global.focus_char:
		return
	update_char_info()
	update_weapon_buttons()
	update_weapon_buttons_text()
	update_active_category_buttons()
	update_active_attack_buttons()
	update_activity_buttons()
	update_action_pips()
	update_spell_list()
	update_concentration_slots()
	await get_tree().process_frame
	#Global.ui_log.scroll_vertical = Global.ui_log.get_line_count()

func _on_activity_button_toggled(pressed: bool, button: TextureButton):
	var activity = button.get_meta("activity")
	if not activity:
		return

	Global.focus_char.perform_activity(activity, Global.focus_char)

	var active = Global.focus_char.has_condition(activity.condition_id)

	button.set_pressed_no_signal(active)
	_set_button_active(button, active)

	#var icon = button.get_node("Icon") as TextureRect
	#var mat = icon.material as ShaderMaterial
	#
	#if pressed:
		#SignalBus.dialog_show_message.emit("Button toggle: On")
		#if activity and activity.has_method("execute"):
			#Global.focus_char.perform_activity(activity)
		#else:
			#print("Invalid or missing activity.")
		#if mat:
			#mat.set_shader_parameter("outline_thickness", 2)
	#else:
		#SignalBus.dialog_show_message.emit("Button toggle: Off")
		#if activity and activity.has_method("execute"):
			#Global.focus_char.perform_activity(activity)
		#else:
			#print("Invalid or missing activity.")
		#if mat:
			#mat.set_shader_parameter("outline_thickness", 0)


func _on_activity_button_pressed(button: TextureButton):
	var activity = button.get_meta("activity")
	if not activity:
		return
	
	if activity and activity.has_method("execute"):
		Global.focus_char.perform_activity(activity)
	else:
		print("Invalid or missing activity.")

func _on_toggle_end_turn_button():
	var end_turn_button = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/EndTurnButton")

	if end_turn_button.disabled == true:
		end_turn_button.disabled = false
	else:
		end_turn_button.disabled = true

func _on_crisis_state_changed():
	var crisis_button = ui_node.get_node("PanelContainer/VBoxContainer/HBoxContainer/VBoxContainer2/CrisisModeButton")
	crisis_button.set_pressed_no_signal(Global.crisis_manager.crisis_mode)

func _on_slider_value_changed(value):
	var character = Global.selected_char.data
	var slider = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/SpellRankSlider")
	character.current_spell_rank = value
	slider.tooltip_text = "Spell rank selected: %d" % character.current_spell_rank
	
	var PP_bar_preview = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/PP_bar_wrapper/PP_bar_preview")
	PP_bar_preview.visible = true
	
	var current_level_table = character.casting_table.cost_table[character.level - 1]
	var cost = current_level_table.spell_costs[character.current_spell_rank]
	character.derived_stats.current_spell_cost = cost
	PP_bar_preview.value = character.current_pp - cost
	#SignalBus.dialog_show_message.emit("PP bar value: %d" % PP_bar_preview.value)

#func update_spell_rank_slider():
	#var slider = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/SpellRankSlider")
	#var PP_bar_preview = ui_node.get_node_or_null("PanelContainer/VBoxContainer/HBoxContainer/CharInfoVBox1/PP_bar_wrapper/PP_bar_preview")
	#PP_bar_preview.value = character.current_pp - current_spell_cost

func _ready() -> void:
	SignalBus.update_inventory.connect(_on_update_inventory_window)
	SignalBus.update_character_info.connect(_on_update_character_info)
	SignalBus.drop_item_on_tile.connect(_on_drop_item_on_tile)
	SignalBus.update_ui_for_char.connect(update_ui_for_char)
	SignalBus.toggle_end_turn_button.connect(_on_toggle_end_turn_button)
	SignalBus.crisis_state_changed.connect(_on_crisis_state_changed)
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	#await get_tree().create_timer(0.1).timeout
