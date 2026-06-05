extends Entity
class_name Creature

@export var data: CreatureData
@export var health_bar_scene: PackedScene

@onready var sprite_node = $Mover/Sprite2D
@onready var vfx_container = $Mover/VFXContainer
@onready var ai_controller = $AIController

@onready var mover = $Mover

var health_bar_instance: Node

# Meta utility 
var reachable_tiles: Array = []
var stats_dirty: bool = true
var mutation_depth: int = 0
var active_right_click: Activity

func start_mutation():
	stats_dirty = true
	mutation_depth += 1
	
func end_mutation():
	mutation_depth -= 1
	
	if mutation_depth < 0:
		push_error("Mutation depth below zero!")
		mutation_depth = 0

	if mutation_depth == 0:
		update_stats()

func add_activity(activity: ActivityContainer):
	if activity not in data.activities:
		data.activities.append(activity)

func add_ready_spell(spell: SpellContainer):
	if spell not in data.spells_ready:
		data.spells_ready.append(spell)

func remove_ready_spell(spell: SpellContainer):
	if spell in data.spells_ready:
		data.spells_ready.erase(spell)

func add_available_spell(spell: SpellContainer):
	if spell not in data.spells_available:
		data.spells_available.append(spell)
	
func add_concentration(concentration: Concentration):
	data.concentrations.append(concentration)
	SignalBus.update_ui_for_char.emit()

func toggle_activity_modifier(modifier: Modifier) -> void:
	for existing_mod in data.activity_modifiers:
		if existing_mod.id == modifier.id:
			data.activity_modifiers.erase(existing_mod)
		else:
			data.activity_modifiers.append(modifier)

func add_activity_modifier(modifier: Modifier) -> void:
	data.activity_modifiers.append(modifier)
	SignalBus.update_ui_for_char.emit()

func remove_activity_modifier(modifier: Modifier) -> void:
	for existing_mod in data.activity_modifiers:
		if existing_mod.id == modifier.id:
			data.activity_modifiers.erase(existing_mod)
			return

func remove_concentration(concentration: Concentration):
	data.concentrations.erase(concentration)
	SignalBus.update_character_info.emit()
	SignalBus.update_ui_for_char.emit()

func add_barrier(barrier: Barrier, ctx: Context) -> void:
	var instance = barrier.duplicate(true)
	instance.parent_creature = self
	instance.parent_condition = ctx.condition
	var barriers: Array[Barrier] = data.barriers
	barriers.append(instance)
	barriers.sort_custom(func(a, b): return a.priority < b.priority)

func process_barriers(ctx: ActivityContext) -> void:
	var barriers: Array[Barrier] = data.barriers
	for barrier in barriers:
		if barrier.handle_activity(ctx):
			return

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
	#stats_dirty = true

func remove_talent(talent: Talent):
	start_mutation()
	for existing_talent in data.talents:
		if existing_talent.name == talent.name:
			data.talents.erase(existing_talent)
	end_mutation()

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

## Returns the new condition instance on adding the condition, null on removing it
func toggle_condition(ctx: Context) -> Condition:
	var existing = get_condition_by_id(ctx.condition.id)

	if existing:
		start_mutation()
		existing.remove_source(ctx.id)
		end_mutation()
		return null
	else:
		return add_condition_from(ctx)

func add_condition_from(ctx: Context) -> Condition:
	var existing = get_condition_by_id(ctx.condition.id)

	if existing:
		existing.add_source(ctx.id)
		return existing

	for weaker_cond in ctx.condition.supplanted:
		if has_condition(weaker_cond.id):
			remove_condition(weaker_cond)
	for existing_cond in data.conditions:
		for weaker_cond in existing_cond.supplanted:
			if ctx.condition.id == weaker_cond.id:
				return existing_cond

	var inst = ctx.condition.duplicate(true)
	inst.add_source(ctx.id)
	data.conditions.append(inst)
	inst.initialize(ctx)
	if Global.selected_char == self:
		SignalBus.update_ui_for_char.emit()
		SignalBus.update_character_info.emit()
	return inst

func remove_condition_by_id(condition_id: String):
	start_mutation()
	var condition = null
	for existing_cond in data.conditions:
		if existing_cond.id == condition_id:
			condition = existing_cond
	if not condition:
		return
	data.conditions.erase(condition)
	end_mutation()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()

func remove_condition(condition: Condition):
	start_mutation()
	for existing_cond in data.conditions:
		if existing_cond.id == condition.id:
			data.conditions.erase(existing_cond)
	end_mutation()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()

#func remove_condition(condition: Condition):
	#for effect in condition.effects:
		#if effect.has_method("remove_context"):
			#var ctx = Context.new()
			#ctx.user = self
			#ctx.origin = self
			#ctx.target = self
			#ctx.condition = condition
			#effect.remove_context(ctx)
		#else:
			#effect.remove(self, self, -1)
	#for existing_cond in data.conditions:
		#if existing_cond.id == condition.id:
			#data.conditions.erase(existing_cond)
	#if Global.selected_char == self:
		#SignalBus.update_inventory.emit()
		#SignalBus.update_character_info.emit()

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
			ctx.condition = instance
			add_condition_from(ctx)
		else:
			push_error("Item condition is not a Condition resource: " + str(condition))

func remove_item_conditions(item):
	start_mutation()
	if not item or not item.conditions:
		return
	for item_condition in item.conditions:
		for i in range(data.conditions.size() - 1, -1, -1):
			var cond = data.conditions[i]
			if cond.name == item_condition.name:
				remove_condition(cond)
	end_mutation()

func remove_conditions_from_equipment():
	start_mutation()
	var collection = data.equipment.get_all_equipped_items()
	if collection:
		for item in collection:
			remove_item_conditions(item)
	end_mutation()

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
	start_mutation()
	remove_conditions_from_equipment()
	apply_conditions_from_equipment()
	end_mutation()

func initialize_item(item: Item):
	item.initialize_attack_modes()

func equip_item(item: Item) -> bool:
	initialize_item(item)
	#remove_conditions_from_equipment()
	#if not data.equipment.equip_item(item):
		#apply_conditions_from_equipment()
		#return false
	item.owner = self
	#apply_conditions_from_equipment()
	#update_stats()
	if data.equipment.equip_item(item):
		add_item_conditions(item)
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
	return true

func equip_item_in_slot(item: Item, slot: Enums.EquipmentSlot, force: bool = false) -> bool:
	start_mutation()
	initialize_item(item)
	#remove_conditions_from_equipment()
	if data.equipment.get_item_in_slot(slot):
		if force:
			var old_item: Item = data.equipment.free_slot(slot)
			data.inventory.add_item(old_item)
		else:
			#apply_conditions_from_equipment()
			end_mutation()
			return false
	data.equipment.equip_item_in_slot(item, slot)
	#apply_conditions_from_equipment()
	item.owner = self
	end_mutation()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
	return true

func unequip_slot(slot) -> Item:
	start_mutation()
	#remove_conditions_from_equipment()
	var item: Item = data.equipment.free_slot(slot)
	#apply_conditions_from_equipment()
	end_mutation()
	if Global.selected_char == self:
		SignalBus.update_inventory.emit()
		SignalBus.update_character_info.emit()
	return item

func remove_item(item: Item) -> Item:
	var inventory = get_inventory()
	if item in inventory:
		inventory.remove_from_inventory(item)
	else:
		#remove_conditions_from_equipment()
		start_mutation()
		data.equipment.remove_item(item)
		#apply_conditions_from_equipment()
		end_mutation()
		if Global.selected_char == self:
			SignalBus.update_inventory.emit()
			SignalBus.update_character_info.emit()
	return item

func remove_item_from_slot(slot) -> Item:
	start_mutation()
	var item = data.equipment.remove_item_from_slot(slot)
	end_mutation()
	return item

#func remove_item_from_slot(slot) -> Item:
	#var item: Item = data.equipment.remove_item_from_slot(slot)
	#update_stats()
	#return item

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

func perceive_audibility() -> Enums.Capability:
	return data.audibility

func perceive_visibility() -> Enums.Capability:
	return data.visibility

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

func has_enough_ap(number: int) -> bool:
	if Global.crisis_manager.crisis_mode:
		if data.current_ap - number < 0:
			return false
	return true
	
func has_enough_pp(number: int) -> bool:
	if data.current_pp - number < 0:
			return false
	return true

## consumes AP and potentially associated MP if set to 'true'
func consume_ap(number: int, mp_equivalent: bool = true) -> bool:
	if Global.crisis_manager.crisis_mode:
		if data.current_ap - number < 0:
			return false
		data.current_ap -= number
		if data.current_ap < 0:
			data.current_ap = 0
		if mp_equivalent:
			consume_mp(number * get_stat("max_mp"))
			if Global.selected_char == self:
				Global.world_manager.path_preview.get_char_data()
	return true

func consume_pp(number) -> bool:
	if data.current_pp - number < 0:
			return false
	data.current_pp -= number
	if data.current_pp < 0:
		data.current_pp = 0
	return true

func consume_mp(number) -> bool:
	if data.current_mp - number < 0:
			return false
	data.current_mp -= number
	if data.current_mp < 0:
		data.current_mp = 0
	return true

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

func get_modified_activity(activity_variant: ActivityVariant) -> Activity:
	var instance = activity_variant.produce(self)

	for modifier in data.activity_modifiers:
			instance.modifiers.append(modifier)

	return instance

func perform_activity_variant(activity_variant: ActivityVariant, target: Node = null):
	var activity = get_modified_activity(activity_variant)
	activity.user = self
	if target:
		activity.target_entities.append(target)
	activity.execute()

func perform_activity(activity: Activity, target = null):
	activity.user = self
	if target:
		activity.target_points.append(target)
		#activity.target_entities.append(target)
	activity.execute()

func get_selected_weapon_activity() -> Activity:
	var weapons = get_weapons()
	var hand = data.equipment.active_hand
	var category = data.equipment.active_category
	var selected_weapon = weapons[hand]
	var attack_activity: Activity = null
	if selected_weapon:
		if category == Enums.AttackCategory.STRIKE and selected_weapon.strike:
			attack_activity = get_modified_activity(selected_weapon.strike)
			attack_activity.weapon = selected_weapon
		elif category == Enums.AttackCategory.SHOOT and selected_weapon.shoot:
			attack_activity = get_modified_activity(selected_weapon.shoot)
			attack_activity.weapon = selected_weapon
		elif category == Enums.AttackCategory.THROW and selected_weapon.throw:
			attack_activity = get_modified_activity(selected_weapon.throw)
			attack_activity.weapon = selected_weapon
	return attack_activity

func perform_attack(target):
	var attack_activity: Activity = get_selected_weapon_activity()
	if attack_activity:
		perform_activity(attack_activity, target)

func perform_operate(prop: Prop):
	if consume_ap(1):
		prop.operate(self)
		SignalBus.update_ui_for_char.emit()

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

func get_stat_enum(type: Enums.StatType, stat: int) -> int:
	match type:
		Enums.StatType.ATTRIBUTE:
			return data.attributes.get_attribute(stat)
		Enums.StatType.APTITUDE:
			return data.derived_stats.get_aptitude(stat)
		Enums.StatType.SKILL:
			return data.derived_stats.get_skill(stat)
		Enums.StatType.POINT:
			return data.derived_stats.get_points(stat)
		Enums.StatType.RESISTANCE:
			return data.resistances.get_resistance(stat)
	return 0

func set_stat_enum(type: Enums.StatType, stat: int, value: int) -> void:
	match type:
		Enums.StatType.ATTRIBUTE:
			data.attributes.set_attribute(stat, value)
		Enums.StatType.APTITUDE:
			data.derived_stats.set_aptitude(stat, value)
		Enums.StatType.SKILL:
			data.derived_stats.set_skill(stat, value)
		Enums.StatType.POINT:
			data.derived_stats.set_points(stat, value)
		Enums.StatType.RESISTANCE:
			data.resistances.set_resistance(stat, value)

func modify_stat(operation: Enums.Operation, type: Enums.StatType, stat: int, value: int) -> void:
	var current_value = get_stat_enum(type, stat)
	match operation:
		Enums.Operation.ADD:
			set_stat_enum(type, stat, current_value + value)
		Enums.Operation.MULTIPLY:
			set_stat_enum(type, stat, current_value * value)
		Enums.Operation.REPLACE:
			set_stat_enum(type, stat, value)

func change_status(type: Enums.Status, new_status: int):
	match type:
		Enums.Status.STATE:
			data.state = new_status as Enums.State
		Enums.Status.SIGHT:
			data.sight = new_status as Enums.Capability
		Enums.Status.HEARING:
			data.hearing = new_status as Enums.Capability
		Enums.Status.VISIBILITY:
			data.visibility = new_status as Enums.Capability
		Enums.Status.AUDIBILITY:
			data.audibility = new_status as Enums.Capability

func change_stat_enum(type: Enums.StatType, stat: int, delta):
	match type:
		Enums.StatType.ATTRIBUTE:
			pass
		Enums.StatType.APTITUDE:
			var current = data.derived_stats.get_aptitude(stat)
			data.derived_stats.set_aptitude(stat, current + delta)
		Enums.StatType.SKILL:
			var current = data.derived_stats.get_skill(stat)
			data.derived_stats.set_skill(stat, current + delta)
		Enums.StatType.POINT:
			var current = data.derived_stats.get_points(stat)
			data.derived_stats.set_points(stat, current + delta)
			if stat == Enums.Point.MAX_MP:
				update_mover_speed()
		Enums.StatType.RESISTANCE:
			#var current = data.derived_stats.get_resistance(stat)
			#data.derived_stats.set_resistance(stat, current + delta)
			# To remove once I've fully moved towards using derived_stats:
			var current = data.resistances.get_resistance(stat)
			data.resistances.set_resistance(stat, current + delta)

func replace_stat_enum(type: Enums.StatType, stat: int, value):
	match type:
		Enums.StatType.ATTRIBUTE:
			pass
		Enums.StatType.APTITUDE:
			data.derived_stats.set_aptitude(stat, value)
		Enums.StatType.SKILL:
			data.derived_stats.set_skill(stat, value)
		Enums.StatType.POINT:
			data.derived_stats.set_points(stat, value)
			if stat == Enums.Point.MAX_MP:
				update_mover_speed()
		Enums.StatType.RESISTANCE:
			#var current = data.derived_stats.get_resistance(stat)
			#data.derived_stats.set_resistance(stat, current + delta)
			# To remove once I've fully moved towards using derived_stats:
			data.resistances.set_resistance(stat, value)

func multiply_stat_enum(type: Enums.StatType, stat: int, factor):
	match type:
		Enums.StatType.ATTRIBUTE:
			pass
		Enums.StatType.APTITUDE:
			var current = data.derived_stats.get_aptitude(stat)
			data.derived_stats.set_aptitude(stat, current * factor)
		Enums.StatType.SKILL:
			var current = data.derived_stats.get_skill(stat)
			data.derived_stats.set_skill(stat, current * factor)
		Enums.StatType.POINT:
			var current = data.derived_stats.get_points(stat)
			data.derived_stats.set_points(stat, current * factor)
			if stat == Enums.Point.MAX_MP:
				update_mover_speed()
		Enums.StatType.RESISTANCE:
			#var current = data.derived_stats.get_resistance(stat)
			#data.derived_stats.set_resistance(stat, current + delta)
			# To remove once I've fully moved towards using derived_stats:
			var current = data.resistances.get_resistance(stat)
			data.resistances.set_resistance(stat, current * factor)

## @deprecated: use change_stat_enum() instead
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

#func senses_check_on_tile(target_tile) -> bool: 
	#if hearing_check(target_tile):
		#return true
	#if sight_check(target_tile):
		#return true
	#return false

func discover_creature(creature):
	var uid = creature.data.uid

	if not data.relationships._tactical_map.has(uid):
		var entry = TacticalRelationEntry.new()
		entry.target_id = uid
		entry.last_updated_turn = Global.crisis_manager.crisis_round
		data.relationships._tactical_map[uid] = entry
		set_hostile(uid, 100)
		for affiliation in creature.data.relationships.affiliations:
			if affiliation.faction == "bandits":
				set_hostile(uid, 0)

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

func get_current_spell_rank_table():
	@warning_ignore("integer_division")
	return data.casting_table.cost_table[(data.level - 1) / 2]

func set_max_spell_rank() -> void:
	@warning_ignore("integer_division")
	var current_spell_rank_table = get_current_spell_rank_table()
	data.max_spell_rank = current_spell_rank_table.spell_costs.keys().max()

func get_current_spell_cost() -> int:
	return get_current_spell_rank_table().spell_costs[data.current_spell_rank]

## This initalises the base stats, meant to be used on spawn and at every level-up, and not accessed from outside the class
func build_stats():
	if not data.has_been_initialized:
		if data.uid == 0:
			data.uid = Global.state_manager.next_uid(Enums.UIDType.CREATURE)
		if data.id == 0:
			data.id = data.uid

		_duplicate_runtime_resources()
		data.derived_stats = DerivedStats.new()

		data.relationships  = _ensure_resource(data.relationships, func(): return Relationships.new())
		data.attributes     = _ensure_resource(data.attributes, func(): return Attributes.new())
		data.skills         =_ensure_resource(data.skills, func(): return Skills.new())
		data.base_stats     = _ensure_resource(data.base_stats, func(): return BaseStats.new())
		data.inventory      = _ensure_resource(data.inventory, func(): return Inventory.new())
		data.equipment      = _ensure_resource(data.equipment, func(): return Equipment.new())
		data.resistances    = _ensure_resource(data.resistances, func(): return Resistances.new())
		data.personality    = _ensure_resource(data.personality, func(): return Personality.new())

		@warning_ignore("integer_division")
		data.base_stats.level_mod = max(1, data.level / 2)
		data.base_stats.agility = data.attributes.dexterity + data.base_stats.level_mod
		data.base_stats.will = data.attributes.resolve + data.base_stats.level_mod
		data.base_stats.sense = data.attributes.acuity + data.base_stats.level_mod
		data.base_stats.stamina = data.attributes.brawn + data.base_stats.level_mod
		data.base_stats.offence = data.attributes.acuity + data.base_stats.level_mod
		data.base_stats.melee_defence = data.attributes.dexterity + data.base_stats.level_mod
		data.base_stats.ranged_defence = data.attributes.dexterity + data.base_stats.level_mod

		data.base_stats.arcane = data.skills.arcane + data.base_stats.level_mod
		data.base_stats.artistry = data.skills.artistry + data.base_stats.level_mod
		data.base_stats.society = data.skills.society + data.base_stats.level_mod
		data.base_stats.craftsmanship = data.skills.craftsmanship + data.base_stats.level_mod
		data.base_stats.deception = data.skills.deception + data.base_stats.level_mod
		data.base_stats.history = data.skills.history + data.base_stats.level_mod
		data.base_stats.linguistics = data.skills.linguistics + data.base_stats.level_mod
		data.base_stats.mechanics = data.skills.mechanics + data.base_stats.level_mod
		data.base_stats.medicine = data.skills.medicine + data.base_stats.level_mod
		data.base_stats.nature = data.skills.nature + data.base_stats.level_mod
		data.base_stats.persuasion = data.skills.persuasion + data.base_stats.level_mod
		data.base_stats.thievery = data.skills.thievery + data.base_stats.level_mod
		data.base_stats.stealth = data.skills.stealth + data.base_stats.level_mod

		data.base_stats.strength_bonus = data.attributes.brawn
		#data.base_stats.size = "medium"

		data.base_stats.max_hp = (data.attributes.brawn * 12) + (data.attributes.brawn * data.base_stats.level_mod)
		data.current_hp = data.base_stats.max_hp
		data.base_stats.max_pp = data.attributes.resolve * data.base_stats.level_mod
		data.current_pp = data.base_stats.max_pp
		data.base_stats.max_ep = (data.attributes.brawn * 12) + (data.attributes.brawn * data.base_stats.level_mod)
		data.current_ep = data.base_stats.max_ep

		data.base_stats.max_mp = data.attributes.dexterity
		
		data.current_ap = data.base_stats.max_mp

		if data.major_archetype and data.major_archetype.type == Enums.Archetype.SCHOLASTIC_MAGE:
			data.max_spells_ready = data.attributes.acuity
		else:
			data.max_spells_ready = 999

		data.talents.clear()
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
			set_max_spell_rank()

		data.spells_ready.clear()
		#if data.major_archetype and data.major_archetype.type == Enums.Archetype.ASPECTED_MAGE:
			#for spell in data.spells_available:
				#add_ready_spell(spell)

		data.has_been_initialized = true
		update_stats()
		print("character file ready.")

## This builds the final usable stats; to be used directly for activities and from outside the class
func update_stats():
	data.derived_stats.agility = data.base_stats.agility + data.derived_stats.vigour
	data.derived_stats.will = data.base_stats.will + data.derived_stats.vigour
	data.derived_stats.sense = data.base_stats.sense + data.derived_stats.vigour
	data.derived_stats.stamina = data.base_stats.stamina + data.derived_stats.vigour
	data.derived_stats.offence = data.base_stats.offence + data.derived_stats.vigour
	data.derived_stats.melee_defence = data.base_stats.melee_defence + data.derived_stats.vigour
	data.derived_stats.ranged_defence = data.base_stats.ranged_defence + data.derived_stats.vigour
	
	data.derived_stats.arcane = data.base_stats.arcane + data.derived_stats.vigour
	data.derived_stats.artistry = data.base_stats.artistry + data.derived_stats.vigour
	data.derived_stats.society = data.base_stats.society + data.derived_stats.vigour
	data.derived_stats.craftsmanship = data.base_stats.craftsmanship + data.derived_stats.vigour
	data.derived_stats.deception = data.base_stats.deception + data.derived_stats.vigour
	data.derived_stats.history = data.base_stats.history + data.derived_stats.vigour
	data.derived_stats.linguistics = data.base_stats.linguistics + data.derived_stats.vigour
	data.derived_stats.mechanics = data.base_stats.mechanics + data.derived_stats.vigour
	data.derived_stats.medicine = data.base_stats.medicine + data.derived_stats.vigour
	data.derived_stats.nature = data.base_stats.nature + data.derived_stats.vigour
	data.derived_stats.persuasion = data.base_stats.persuasion + data.derived_stats.vigour
	data.derived_stats.thievery = data.base_stats.thievery + data.derived_stats.vigour
	data.derived_stats.stealth = data.base_stats.stealth + data.derived_stats.vigour
	
	data.derived_stats.strength_bonus = data.base_stats.strength_bonus
	data.derived_stats.vigour = 0
	#data.base_stats.size = "medium"
	
	data.derived_stats.max_hp = data.base_stats.max_hp
	data.derived_stats.max_pp = data.base_stats.max_pp
	data.derived_stats.max_ep = data.base_stats.max_ep
	
	data.derived_stats.max_mp = data.base_stats.max_mp + data.derived_stats.vigour
	
	data.derived_stats.max_ap = data.base_stats.max_ap
	data.derived_stats.max_reactions = data.base_stats.max_reactions
	
	data.derived_stats.tie_breaker = randf()
	
	data.resistances.physical = 0
	data.resistances.heat = 0
	data.resistances.cold = 0
	data.resistances.electricity = 0
	data.resistances.corrosion = 0
	data.resistances.poison = 0
	data.resistances.psychic = 0
	
	data.sight = Enums.Capability.NORMAL
	data.hearing = Enums.Capability.NORMAL

	data.visibility = Enums.Capability.NORMAL
	data.audibility = Enums.Capability.NORMAL

	data.state = Enums.State.CONSCIOUS
	
	data.targetable = true
	
	#var talents = data.talents
	#for i in range(talents.size() - 1, -1, -1):
		#var talent: Talent = talents[i]
		#if talent.re_apply_effects:
			#talent.initialize(self)
	
	var conditions = data.conditions
	for i in range(conditions.size() - 1, -1, -1):
		var condition = conditions[i]
		if condition.persistent:
			if condition.re_apply_effects:
				condition.apply_effects()
		else:
			conditions.remove_at(i)
	
	apply_conditions_from_equipment()
	
	stats_dirty = false
	sprite_node.texture = load(data.sprite)
	build_tactical_map()
	#set_stat("current_ap", get_stat("max_ap"))
	update_mover_speed()
	SignalBus.add_to_initiative.emit(self)
	SignalBus.update_ui_for_char.emit()

func update_mover_speed() -> void:
	$Mover.max_speed = get_stat("max_mp") * Global.TILE_SIZE * 0.5

func turn_start():
	if data.state == Enums.State.CONSCIOUS:
		set_stat("current_ap", get_stat("max_ap"))
		set_stat("current_mp", (get_stat("max_mp") * get_stat("max_ap")))
	else:
		set_stat("current_ap", 0)
		set_stat("current_mp", 0)
	Global.focus_char = self
	
	handle_tile_conditions()
	
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

func handle_tile_conditions():
	var wm = Global.world_manager
	var layer_tile: Vector2i = Vector2i(data.tile_x, data.tile_y)
	if wm.layers[data.tile_z]["contents"].has(layer_tile):
		for element in wm.layers[data.tile_z]["contents"][layer_tile]:
			if element is AreaCondition and element.trigger == Enums.AreaConditionTrigger.TURN_START:
				element.apply_to_entity(self)

func sight_check(target_tile: Vector3i, creature: Creature = null) -> bool: 
	var origin_tile = Vector3i(data.tile_x, data.tile_y, data.tile_z)
	if WorldMath.pos_in_range_weighted_3d(origin_tile, target_tile, (data.base_stats.sense * 4)):
		if WorldMath.has_line_of_sight_tile(origin_tile, target_tile):
			var sight = creature.data.sight
			var creature_visibility = creature.perceive_visibility()
			match sight:
				Enums.Capability.NIL:
					return false
				Enums.Capability.LOW:
					return true if creature_visibility == Enums.Capability.HIGH else false
				Enums.Capability.NORMAL:
					return true if creature_visibility >= Enums.Capability.NORMAL else false
				Enums.Capability.HIGH:
					return true if creature_visibility >= Enums.Capability.LOW else false
			if creature.data.sight >= Enums.Capability.LOW and creature.perceive_visibility() >= Enums.Capability.LOW:
				return true
	return false

#func sight_check(target_tile: Vector3i, creature: Creature = null) -> bool: 
	#var origin_tile = Vector3i(data.tile_x, data.tile_y, data.tile_z)
	#if WorldMath.pos_in_range_weighted_3d(origin_tile, target_tile, (data.base_stats.sense * 4)):
		#if WorldMath.has_line_of_sight_tile(origin_tile, target_tile):
			#if creature and creature.perceive_visibility() >= Enums.Capability.LOW:
				#return true
	#return false

func hearing_check(strength: int, difficulty_to_perceive: float) -> bool: 
	var acuity = data.attributes.acuity
	var threshold = difficulty_to_perceive - strength
	if acuity >= threshold:
		return true
	return false

#func hearing_check(strength: int, difficulty_to_perceive: float, creature: Creature = null) -> bool: 
	#var acuity: int = data.attributes.acuity
	#var creature_audibility = creature.perceive_audibility()
	#var audibility_modifier: float
	#match creature_audibility:
		#Enums.Capability.NIL:
			#audibility_modifier = 0
		#Enums.Capability.LOW:
			#audibility_modifier = 0.5
		#Enums.Capability.NORMAL:
			#audibility_modifier = 1
		#Enums.Capability.HIGH:
			#audibility_modifier = 2
	#@warning_ignore("narrowing_conversion")
	#strength *= audibility_modifier
	#var threshold = difficulty_to_perceive - strength
	#if acuity >= threshold:
		#return true
	#return false

#func hearing_check(noise_value: int) -> bool: 
	#var acuity = data.attributes.acuity
	#var threshold = max(1, 13 - acuity)
	#if noise_value >= threshold:
		#return true
	#return false

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

func destroy_self():
	var wm = Global.world_manager
	var layer_coords = Vector2i(data.tile_x, data.tile_y)
	wm.layers[data.tile_z]["path_map"].set_point_solid(layer_coords, false)
	wm.layers[data.tile_z]["cover"][layer_coords] = Enums.Cover.NONE
	wm.layers[data.tile_z]["occupied"][layer_coords] = false
	wm.remove_from_tile(self, get_coords())
	wm.current_world.unregister_creature(self)
	Global.crisis_manager.remove_from_initiative_order(self)
	queue_free()

func _ready():
	print("Creature getting ready!")
	if not health_bar_scene:
		print("Health bar scene not set!")
	health_bar_instance = health_bar_scene.instantiate()
	$Mover.add_child(health_bar_instance)
	mover.position = Vector2.ZERO
	$Mover/DamageVisual.hit_material = sprite_node.material as ShaderMaterial
	
