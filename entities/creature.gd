extends Entity
class_name Creature

@export var data: CreatureData
@export var health_bar_scene: PackedScene

@onready var sprite_node = $Mover/Sprite2D
@onready var ai_controller = $AIController

@onready var mover = $Mover

var health_bar_instance: Node

# Meta utility 
var reachable_tiles = []
var stats_dirty = true
var active_right_click: Activity

func add_activity(activity: Activity):
	if activity not in data.activities:
		data.activities.append(activity)

func add_ready_spell(spell: Spell):
	if spell not in data.spells_ready:
		data.spells_ready.append(spell)
	
func add_concentration(concentration: Concentration):
	data.concentrations.append(concentration)
	SignalBus.update_ui_for_char.emit()

func toggle_activity_modifier(modifier: ActivityModifier) -> void:
	for existing_mod in data.activity_modifiers:
		if existing_mod.id == modifier.id:
			data.activity_modifiers.erase(existing_mod)
		else:
			data.activity_modifiers.append(modifier)

func add_activity_modifier(modifier: ActivityModifier) -> void:
	data.activity_modifiers.append(modifier)
	SignalBus.update_ui_for_char.emit()

func remove_activity_modifier(modifier: ActivityModifier) -> void:
	for existing_mod in data.activity_modifiers:
		if existing_mod.id == modifier.id:
			data.conditions.erase(existing_mod)
			return

func remove_concentration(concentration: Concentration):
	data.concentrations.erase(concentration)

func add_talent(talent: Talent):
	for weaker_talent in talent.supplanted:
		if has_talent_named(weaker_talent.name):
			remove_talent(weaker_talent)
	for existing_talent in data.talents:
		for weaker_talent in existing_talent.supplanted:
			if talent.name == weaker_talent.name:
				return
	data.talents.append(talent)
	talent.initialize(self)
	stats_dirty = true

func remove_talent(talent: Talent):
	for existing_talent in data.talents:
		if existing_talent.name == talent.name:
			data.talents.erase(existing_talent)
	stats_dirty = true

func has_talent_named(talent_name: String) -> bool:
	for talent in data.talents:
		if talent.name == talent_name:
			return true
	return false

func has_condition_named(condition_name: String) -> bool:
	for condition in data.conditions:
		if condition.name == condition_name:
			return true
	return false

## Takes the id of the condition as parameter
func has_condition(condition_id: String) -> bool:
	for condition in data.conditions:
		if condition.id == condition_id:
			return true
	return false

func get_condition_by_id(condition_id) -> Condition:
	for condition in data.conditions:
		if condition.id == condition_id:
			return condition
	return null

func toggle_condition(cond: Condition, ctx: Context):
	var existing = get_condition_by_id(cond.id)

	if existing:
		existing.remove_source(ctx.id)
	else:
		add_condition_from(ctx, cond)

func add_condition_from(ctx: Context, cond: Condition):
	var existing = get_condition_by_id(cond.id)

	if existing:
		existing.add_source(ctx.id)
		return

	for weaker_cond in cond.supplanted:
		if has_condition(weaker_cond.id):
			remove_condition(weaker_cond)
	for existing_cond in data.conditions:
		for weaker_cond in existing_cond.supplanted:
			if cond.id == weaker_cond.id:
				return

	var inst = cond.duplicate(true)
	inst.add_source(ctx.id)
	data.conditions.append(inst)
	inst.initialize(ctx)

#func add_condition_from(source, cond: Condition):
	#var existing = get_condition_by_id(cond.id)
#
	#if existing:
		#existing.add_source(source.id)
		#return
#
	#for weaker_cond in cond.supplanted:
		#if has_condition(weaker_cond.id):
			#remove_condition(weaker_cond)
	#for existing_cond in data.conditions:
		#for weaker_cond in existing_cond.supplanted:
			#if cond.id == weaker_cond.id:
				#return
#
	#var inst = cond.duplicate(true)
	#inst.add_source(source.id)
	#data.conditions.append(inst)
	#inst.initialize(self, source)

#func add_condition(condition: Condition):
	#if has_condition(condition.id):
		#return
	#for weaker_cond in condition.supplanted:
		#if has_condition(weaker_cond.id):
			#remove_condition(weaker_cond)
	#for existing_cond in data.conditions:
		#for weaker_cond in existing_cond.supplanted:
			#if condition.id == weaker_cond.id:
				#return
	#data.conditions.append(condition)
	#condition.initialize(self)
	#stats_dirty = true

## Unused?
#func remove_condition_from(source, id: String):
	#var cond = get_condition_by_id(id)
	#if not cond:
		#return
#
	#cond.remove_source(source.id)
#
	#if not cond.has_sources():
		#remove_condition(cond)

#func make_active_set(number):
	#if number not in [0, 1]:
		#return
	#remove_conditions_from_equipment()
	#data.equipment.active_set = number
	#apply_conditions_from_equipment()

#func get_active_weapons():
	#return data.equipment.get_active_weapons()

#func get_active_strike_type():
	#return data.equipment.get_active_strike_type()

#func get_active_set():
	#return data.equipment.active_set

#func set_active_set(number: int):
	#if number == 0 or number == 1:
		#data.equipment.active_set = number

#func get_weapon_slot(slot):
	#return data.equipment.get_weapon_slot(slot)

func remove_condition_by_id(condition_id: String):
	var condition = null
	for existing_cond in data.conditions:
		if existing_cond.id == condition_id:
			condition = existing_cond
	if not condition:
		return
	for effect in condition.effects:
		effect.remove(self, self)
	data.conditions.erase(condition)

func remove_condition(condition: Condition):
	for effect in condition.effects:
		effect.remove(self, self, -1)
	for existing_cond in data.conditions:
		if existing_cond.id == condition.id:
			data.conditions.erase(existing_cond)
	stats_dirty = true

func add_item_conditions(item):
	if not item or not item.conditions:
		return
	for condition in item.conditions:
		if condition is Condition:
			var instance = condition.duplicate(true)
			var ctx = Context.new()
			ctx.id = item.id
			ctx.user = self
			ctx.origin = self
			ctx.target = self
			add_condition_from(ctx, instance)
		else:
			push_error("Item condition is not a Condition resource: " + str(condition))

func remove_item_conditions(item):
	if not item or not item.conditions:
		return
	for item_condition in item.conditions:
		for i in range(data.conditions.size() - 1, -1, -1):
			var cond = data.conditions[i]
			if cond.name == item_condition.name:
				remove_condition(cond)

func remove_conditions_from_equipment():
	var collection = data.equipment.get_all_equipped_items()
	if collection:
		for item in collection:
			remove_item_conditions(item)

func apply_conditions_from_equipment():
	var collection = data.equipment.get_all_equipped_items()
	if collection:
		for item in collection:
			add_item_conditions(item)

func remove_from_inventory(item):
	data.inventory.remove_from_inventory(item)

func get_inventory():
	return data.inventory.get_inventory()

func get_active_hand():
	return data.equipment.active_hand

func set_active_hand(number: int):
	if number == 0 or number == 1:
		data.equipment.active_hand = number

func get_weapons() -> Array[Item]:
	var weapons = data.equipment.get_items_of_slot_type(Enums.SlotType.HAND)
	return weapons

func get_active_weapon() -> Item:
	var weapons = data.equipment.get_items_of_slot_type(Enums.SlotType.HAND)
	var selected_weapon = weapons[data.equipment.active_hand]
	return selected_weapon

func get_item_in_slot(slot):
	return data.equipment.get_item_in_slot(slot)

func reload_equipment():
	remove_conditions_from_equipment()
	apply_conditions_from_equipment()

func initialize_item(item: Item):
	item.initialize_attack_modes()

func equip_item(item: Item) -> bool:
	initialize_item(item)
	remove_conditions_from_equipment()
	if not data.equipment.equip_item(item):
		apply_conditions_from_equipment()
		return false
	item.owner = self
	apply_conditions_from_equipment()
	update_stats()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
	return true

func equip_item_in_slot(item: Item, slot: Enums.EquipmentSlot, force: bool = false) -> bool:
	initialize_item(item)
	remove_conditions_from_equipment()
	if data.equipment.get_item_in_slot(slot):
		if force:
			var old_item: Item = data.equipment.free_slot(slot)
			data.inventory.add_item(old_item)
		else:
			apply_conditions_from_equipment()
			return false
	data.equipment.equip_item_in_slot(item, slot)
	apply_conditions_from_equipment()
	item.owner = self
	update_stats()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
	return true

func unequip_slot(slot) -> Item:
	remove_conditions_from_equipment()
	var item: Item = data.equipment.free_slot(slot)
	apply_conditions_from_equipment()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
	update_stats()
	return item

func remove_item(item: Item) -> Item:
	var inventory = get_inventory()
	if item in inventory:
		inventory.remove_from_inventory(item)
	else:
		remove_conditions_from_equipment()
		data.equipment.remove_item(item)
		apply_conditions_from_equipment()
		if Global.selected_char == self:
			SignalBus.update_inventory.emit()
			SignalBus.update_character_info.emit()
	return item

func remove_item_from_slot(slot) -> Item:
	return data.equipment.remove_item_from_slot(slot)

## Used when something (usually an activity) deals damage to a creature
func take_damage(damage: int, resistance: Enums.Resistance):
	var value = get_resistance(resistance)
	var resistance_value: int = value if value is int else 0
	var final_damage = (damage - resistance_value)
	if final_damage < 0:
		final_damage = 0
	else:
		$Mover/DamageVisual.play_hit_flash(final_damage)
	change_stat("current_hp", -final_damage)
	health_status_change()
	health_bar_instance.update_hp_bar()
	SignalBus.dialog_damage_taken.emit(data.name, final_damage)

## Used when something (usually an activity) restores health to a creature
func take_healing(healing: int):
	change_stat("current_hp", healing)
	health_status_change()
	health_bar_instance.update_hp_bar()
	SignalBus.dialog_healing_taken.emit(data.name, healing)

func health_status_change():
	var current_hp = get_stat("current_hp") 
	var max_hp = get_stat("max_hp") 
	if current_hp > 0:
		$Mover/DamageVisual.set_healthy_tint()
	if current_hp <= -max_hp:
		set_stat("current_hp", -max_hp)
	if current_hp >= max_hp:
		set_stat("current_hp", max_hp)
	if current_hp < 0:
		data.state = Enums.State.UNCONSCIOUS
		$Mover/DamageVisual.set_wounded_tint()
		if data.crisis_ai_active:
			data.crisis_ai_active = false
			SignalBus.ai_became_inactive.emit(self)
	if current_hp <= -max_hp:
		data.alive = false
		print("character is dead!")
		$Mover/DamageVisual.set_dead_tint()

func perceive_level():
	return data.level

func perceive_armour():
	return data.equipment.slots[Enums.EquipmentSlot.ARMOUR]

func perceive_health():
	return (data.current_hp + data.temp_hp)

func get_current_ap():
	return data.current_ap
	
func get_current_pp():
	return data.current_pp

func can_act() -> bool:
	if data.state == Enums.State.CONSCIOUS:
		return true
	return false

func get_best_state() -> Enums.State:
	if data.current_hp < 0:
		return  Enums.State.UNCONSCIOUS
	return Enums.State.CONSCIOUS

func eat_food(food: Food) -> void:
	data.hunger += food.food_value
	if data.hunger > 10000:
		data.hunger = 10000
	data.inventory.remove_item(food)
	SignalBus.dialog_show_message.emit("You have eaten: %s" % [food.name])
	SignalBus.dialog_show_message.emit("Your hunger is now: %d" % [data.hunger])
	SignalBus.update_inventory.emit()

## consumes AP and potentially associated MP if set to 'true'
func consume_ap(number: int, mp_equivalent: bool = true):
	data.current_ap -= number
	if data.current_ap < 0:
		data.current_ap = 0
	if mp_equivalent:
		data.current_mp -= number * get_stat("max_mp")
		if data.current_mp < 0:
			data.current_mp = 0
		if Global.selected_char == self:
			Global.world_manager.path_preview.get_char_data()

func consume_pp(number):
	data.current_pp -= number
	if data.current_pp < 0:
		data.current_pp = 0

func meets_brawn_requirements() -> bool:
	var weapons = data.equipment.get_items_of_slot_type(Enums.SlotType.HAND)
	var selected_weapon = weapons[data.equipment.active_hand]
	
	var brawn = get_stat("brawn")
	if brawn >= selected_weapon.brawn_req_1h:
		return true
	
	var can_dual_wield: bool = false
	for weapon in weapons:
		if weapon == data.equipment.slots[Enums.EquipmentSlot.HAND_DEFAULT]:
			can_dual_wield = true
	
	if can_dual_wield:
		if brawn >= selected_weapon.brawn_req_2h:
			return true

	return false

func get_modified_activity(base_activity: Activity) -> Activity:
	var result = base_activity.duplicate(true)

	for modifier in data.activity_modifiers:
		result = modifier.modify_activity(result)

	return result

func perform_activity(activity: Activity, target: Node = null):
	var final = get_modified_activity(activity)
	final.user = self
	if final is WeaponActivity:
		final.weapon = activity.weapon
	if target:
		final.target_entities.append(target)
	final.execute()

func perform_attack(target):
	var weapons = get_weapons()
	var hand = data.equipment.active_hand
	var category = data.equipment.active_category
	var selected_weapon = weapons[hand]
	if selected_weapon:
		if category == Enums.AttackCategory.STRIKE and selected_weapon.strike:
			var attack_activity = selected_weapon.strike.duplicate(true)
			attack_activity.weapon = selected_weapon
			perform_activity(attack_activity, target)
		elif category == Enums.AttackCategory.SHOOT and selected_weapon.shoot:
			var attack_activity = selected_weapon.shoot.duplicate(true)
			attack_activity.weapon = selected_weapon
			perform_activity(attack_activity, target)
		elif category == Enums.AttackCategory.THROW and selected_weapon.throw:
			var attack_activity = selected_weapon.throw.duplicate(true)
			attack_activity.weapon = selected_weapon
			perform_activity(attack_activity, target)

func perform_operate(prop: Prop):
	prop.operate(self)

func get_all_equipped_items() -> Array:
	return data.equipment.get_all_equipped_items()

func add_item_to_inventory(item: Item) -> void:
	initialize_item(item)
	data.inventory.add_item(item)
	SignalBus.update_inventory.emit()
	SignalBus.dialog_show_message.emit("Picked up %s." % item.name)

func grab_item_from_coords(item: Item, coords: Vector3i) -> void:
	initialize_item(item)
	Global.world_manager.remove_from_tile(item, coords)
	data.inventory.add_item(item)
	SignalBus.update_inventory.emit()
	SignalBus.dialog_show_message.emit("Picked up %s." % item.name)

func get_base_stat(stat):
	if stat in data:
		return data.get(stat)
	elif stat in data.resistances:
		return data.resistances.get(stat)
	elif stat in data.attributes:
		return data.attributes.get(stat)
	elif stat in data.derived_stats:
		return data.derived_stats.get(stat)
	else:
		push_warning("Could not find stat: ", stat)

func get_final_stat(stat):
	return get_stat(stat)

## @deprecated: use get_final_stat() instead
func get_stat(stat):
	if stat in data:
		return data.get(stat)
	elif stat in data.derived_stats:
		return data.derived_stats.get(stat)
	elif stat in data.resistances:
		return data.resistances.get(stat)
	elif stat in data.base_stats:
		return data.base_stats.get(stat)
	elif stat in data.attributes:
		return data.attributes.get(stat)
	else:
		push_warning("Could not find stat: ", stat)

func set_stat(stat, value):
	if stat in data:
		data.set(stat, value)
	elif stat in data.derived_stats:
		data.derived_stats.set(stat, value)
	elif stat in data.resistances:
		data.resistances.set(stat, value)
	elif stat in data.attributes:
		data.attributes.set(stat, value)
	else:
		push_error("Could not find stat: ", stat)

func change_stat(stat: StringName, delta):
	var current = get_final_stat(stat)
	if current != null:
		set_stat(stat, current + delta)

func get_aptitude(type: Enums.Aptitude) -> int:
	return data.derived_stats.get_aptitude(type)
	
func set_aptitude(type: Enums.Aptitude, value: int) -> void:
	data.derived_stats.set_aptitude(type, value)

func get_resistance(type: Enums.Resistance) -> int:
	return data.resistances.get_resistance(type)

func set_resistance(type: Enums.Resistance, value: int) -> void:
	data.resistances.set_resistance(type, value)

func add_casting_table(table: CastingTable):
	data.casting_table = table

func senses_check_on_tile(target_tile) -> bool: 
	if hearing_check(target_tile):
		return true
	if sight_check(target_tile):
		return true
	return false

func discover_creature(creature):
	var id = creature.data.id

	if not data.relationships._tactical_map.has(id):
		var entry = TacticalRelationEntry.new()
		entry.target_id = id
		entry.last_updated_turn = Global.crisis_manager.crisis_round
		data.relationships._tactical_map[id] = entry
		set_hostile(id, 100)
		for affiliation in creature.data.relationships.affiliations:
			if affiliation.faction == "bandits":
				set_hostile(id, 0)

func evaluate_entering_crisis(creature):
	var rel_entry = get_tactical(creature.data.id)
	if rel_entry:
		if rel_entry.hostile > 0:
			data.crisis_ai_active = true
			SignalBus.ai_became_active.emit(self)
			if not Global.crisis_manager.crisis_mode:
				SignalBus.start_crisis_mode.emit(self)

func build_tactical_map():
	data.relationships.build_tactical_map()

func get_tactical(target_id: int) -> TacticalRelationEntry:
	return data.relationships.get_tactical(target_id)

func set_hostile(target_id: int, value: int):
	data.relationships.set_hostile(target_id, value)

func get_coords() -> Vector3i:
	var pos_3d = Vector3i(
	data.tile_x,
	data.tile_y,
	data.tile_z)
	return pos_3d

func set_coords(new_coords: Vector3i):
	data.tile_x = new_coords.x
	data.tile_y = new_coords.y
	data.tile_z = new_coords.z

## This initalises the base stats, meant to be used on spawn and at every level-up, and not accessed from outside the class
func initialise():
	if not data.has_been_initialized:
		if data.uid == 0:
			data.id = Global.uid_manager.next_uid(UIDManager.Type.CREATURE)
		if data.id == 0:
			data.id = data.uid

		_duplicate_runtime_resources()
		data.derived_stats = DerivedStats.new()

		data.relationships = _ensure_resource(data.relationships, func(): return Relationships.new())
		data.attributes     = _ensure_resource(data.attributes, func(): return Attributes.new())
		data.base_stats     = _ensure_resource(data.base_stats, func(): return BaseStats.new())
		data.inventory      = _ensure_resource(data.inventory, func(): return Inventory.new())
		data.equipment      = _ensure_resource(data.equipment, func(): return Equipment.new())
		data.resistances    = _ensure_resource(data.resistances, func(): return Resistances.new())
		data.personality    = _ensure_resource(data.personality, func(): return Personality.new())

		@warning_ignore("integer_division")
		data.base_stats.level_mod = data.level / 2
		data.base_stats.agility = data.attributes.dexterity + data.base_stats.level_mod
		data.base_stats.will = data.attributes.resolve + data.base_stats.level_mod
		data.base_stats.sense = data.attributes.acuity + data.base_stats.level_mod
		data.base_stats.stamina = data.attributes.brawn + data.base_stats.level_mod
		data.base_stats.offence = data.attributes.acuity + data.base_stats.level_mod
		data.base_stats.melee_defence = data.attributes.dexterity + data.base_stats.level_mod
		data.base_stats.ranged_defence = data.attributes.dexterity + data.base_stats.level_mod

		# skills not implemented yet

		data.base_stats.strength_bonus = data.attributes.brawn
		#data.base_stats.size = "medium"

		data.base_stats.max_hp = (data.attributes.brawn * 12) + (data.attributes.brawn * data.base_stats.level_mod)
		data.current_hp = data.base_stats.max_hp
		data.base_stats.max_pp = data.attributes.resolve * data.base_stats.level_mod
		data.current_pp = data.base_stats.max_pp
		data.base_stats.max_ep = (data.attributes.brawn * 12) + (data.attributes.brawn * data.base_stats.level_mod)
		data.current_ep = data.base_stats.max_ep

		data.base_stats.max_mp = data.attributes.dexterity

		if data.major_archetype:
			for entry in data.major_archetype.talents_by_level:
				if entry.level <= data.level and entry.auto_talents:
					for talent in entry.auto_talents:
						add_talent(talent)
		if data.minor_archetype:
			for entry in data.minor_archetype.talents_by_level:
				if entry.level <= data.level and entry.auto_talents:
					for talent in entry.auto_talents:
						add_talent(talent)

		if data.casting_table:
			var current_level_table := data.casting_table.cost_table[data.level - 1]
			data.max_spell_rank = current_level_table.spell_costs.keys().max()

		data.has_been_initialized = true
		update_stats()
		print("character file ready.")

## This builds the final usable stats; to be used directly for activities and from outside the class
func update_stats():
	if not stats_dirty:
		return
	data.derived_stats.agility = data.base_stats.agility + data.derived_stats.vigour
	data.derived_stats.will = data.base_stats.will + data.derived_stats.vigour
	data.derived_stats.sense = data.base_stats.sense + data.derived_stats.vigour
	data.derived_stats.stamina = data.base_stats.stamina + data.derived_stats.vigour
	data.derived_stats.offence = data.base_stats.offence + data.derived_stats.vigour
	data.derived_stats.melee_defence = data.base_stats.melee_defence + data.derived_stats.vigour
	data.derived_stats.ranged_defence = data.base_stats.ranged_defence + data.derived_stats.vigour
	
	# skills not implemented yet
	
	data.derived_stats.strength_bonus = data.base_stats.strength_bonus
	#data.base_stats.size = "medium"
	
	data.derived_stats.max_hp = data.base_stats.max_hp
	data.derived_stats.max_pp = data.base_stats.max_pp
	data.derived_stats.max_ep = data.base_stats.max_ep
	
	data.derived_stats.max_mp = data.base_stats.max_mp + data.derived_stats.vigour
	
	data.derived_stats.max_ap = data.base_stats.max_ap
	data.derived_stats.max_reactions = data.base_stats.max_reactions
	
	data.derived_stats.tie_breaker = randf()

	#if data.casting_table:
		#var current_level_table = data.casting_table.cost_table[get_stat("level") - 1]
		#var cost = current_level_table.spell_costs[data.current_spell_rank]
		#data.derived_stats.current_spell_cost = cost
	
	stats_dirty = false
	sprite_node.texture = load(data.sprite)
	build_tactical_map()
	set_stat("current_ap", get_stat("max_ap"))
	$Mover.max_speed = get_stat("max_mp") * Global.TILE_SIZE * 0.5
	SignalBus.add_to_initiative.emit(self)
	SignalBus.update_ui_for_char.emit()

func _on_start_crisis():
	update_stats()
	data.current_ap = data.derived_stats.max_ap
	data.current_mp = 0

func turn_start():
	if data.state == Enums.State.CONSCIOUS:
		set_stat("current_ap", get_stat("max_ap"))
		set_stat("current_mp", (get_stat("max_mp") * get_stat("max_ap")))
	else:
		set_stat("current_ap", 0)
		set_stat("current_mp", 0)
	Global.focus_char = self
	if data.player_controlled:
		print("played controlled")
		Global.selected_char = self
		Global.world_manager.selection_highlight.update_selection_highlight()
		SignalBus.update_ui_for_char.emit()
		Global.world_manager.path_preview.get_char_data()
	else:
		print("AI controlled")
		if data.crisis_ai_active:
			print("AI active")
			SignalBus.dialog_show_message.emit("%s is acting." % self.data.name)
			ai_controller.crisisai.plan_turn() 
			SignalBus.turn_ends.emit()
		else:
			# character does their real time routine in turn by turn
			SignalBus.turn_ends.emit()

#func _on_end_turn():
	#data.current_ap = data.derived_stats.max_ap
	#data.current_mp = 0
	#if not data.player_controlled and data.crisis_ai_active:
		#Global.focus_char = self
		#ai_controller.crisisai.plan_turn() 

func sight_check(target_tile) -> bool: 
	var origin_tile = Vector3i(data.tile_x, data.tile_y, data.tile_z)
	if WorldMath.pos_in_range_weighted_3d(origin_tile, target_tile, (data.base_stats.sense * 4)):
		if WorldMath.has_line_of_sight_tile(origin_tile, target_tile):
			return true
	return false

func hearing_check(noise_value: int) -> bool: 
	var acuity = data.attributes.acuity
	var threshold = max(1, 13 - acuity)
	if noise_value >= threshold:
		return true
	return false

#func hearing_check(target_tile) -> bool: 
	#var origin_tile = Vector3i(data.tile_x, data.tile_y, data.tile_z)
	#if WorldMath.pos_in_range_weighted_3d(origin_tile, target_tile, (data.base_stats.sense * 1)):
		#return true
	#return false

func _ensure_resource(res: Resource, ctor: Callable) -> Resource:
	if res:
		return res.duplicate(true)
	return ctor.call()
	
func debug_outline():
	print("debugging outline")
	$Mover/Outline.toggle_outline()

func _duplicate_runtime_resources():
	if data.attributes:
		data.attributes = data.attributes.duplicate(true)
	else:
		data.attributes = Attributes.new()

	if data.base_stats:
		data.base_stats = data.base_stats.duplicate(true)
	else:
		data.base_stats = BaseStats.new()

	if data.inventory:
		data.inventory = data.inventory.duplicate(true)
	else:
		data.inventory = Inventory.new()

	if data.equipment:
		data.equipment = data.equipment.duplicate(true)
	else:
		data.equipment = Equipment.new()

	if data.resistances:
		data.resistances = data.resistances.duplicate(true)
	else:
		data.resistances = Resistances.new()

	if data.relationships:
		data.relationships = data.relationships.duplicate(true)
	else:
		data.relationships = Relationships.new()

func decay_needs(n):
	data.hunger -= 200 * n
	if data.hunger < 0:
		data.hunger = 0
	data.sleep -= 500 * n
	if data.sleep < 0:
		data.sleep = 0
	if not data.player_controlled:
		@warning_ignore("integer_division", "narrowing_conversion")
		data.social -= data.personality.sociality * 10 * n
		if data.social < 0:
			data.social = 0

func _ready():
	print("Creature getting ready!")
	if not health_bar_scene:
		print("Health bar scene not set!")
	health_bar_instance = health_bar_scene.instantiate()
	$Mover.add_child(health_bar_instance)
	mover.position = Vector2.ZERO
	SignalBus.on_start_crisis.connect(_on_start_crisis)
	$Mover/DamageVisual.hit_material = sprite_node.material as ShaderMaterial
	
