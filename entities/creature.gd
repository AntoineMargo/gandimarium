extends Node2D

class_name Creature

@export var data: CreatureData
@export var health_bar_scene: PackedScene

@onready var sprite_node = $Sprite2D
@onready var ai_controller = $AIController

var health_bar_instance: Node

# Meta utility 
var reachable_tiles = []
var stats_dirty = true
var active_right_click: Activity

func update_world_position():
	if Global.current_tile_map_layer and data:
		var tile_pos = Vector2i(self.data.tile_x, self.data.tile_y)
		position = Global.current_tile_map_layer.map_to_local(tile_pos)

func add_activity(activity: Activity):
	if activity not in data.activities:
		data.activities.append(activity)

func add_ready_spell(spell: Spell):
	if spell not in data.spells_ready:
		data.spells_ready.append(spell)
	
func add_concentration(concentration: Concentration):
	data.concentrations.append(concentration)
	SignalBus.update_ui_for_char.emit()

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

func add_condition(condition: Condition):
	if has_condition_named(condition.name):
		return
	for weaker_cond in condition.supplanted:
		if has_condition_named(weaker_cond.name):
			remove_condition(weaker_cond)
	for existing_cond in data.conditions:
		for weaker_cond in existing_cond.supplanted:
			if condition.name == weaker_cond.name:
				return
	data.conditions.append(condition)
	condition.initialize(self)
	stats_dirty = true

func remove_condition(condition: Condition):
	for effect in condition.effects:
		effect.remove(self, self, -1)
	for existing_cond in data.conditions:
		if existing_cond.name == condition.name:
			data.conditions.erase(existing_cond)
	stats_dirty = true

func add_item_conditions(item):
	if not item or not item.conditions:
		return
	for condition in item.conditions:
		if condition is Condition:
			var instance = condition.duplicate()
			add_condition(instance)
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

func make_active_set(number):
	if number not in [0, 1]:
		return
	remove_conditions_from_equipment()
	data.equipment.active_set = number
	apply_conditions_from_equipment()

func add_to_inventory(item):
	data.inventory.add_to_inventory(item)

func remove_from_inventory(item):
	data.inventory.remove_from_inventory(item)

func get_inventory():
	return data.inventory.get_inventory()
	
func get_active_weapons():
	return data.equipment.get_active_weapons()

func get_active_strike_type():
	return data.equipment.get_active_strike_type()

func get_active_set():
	return data.equipment.active_set

func get_active_hand():
	return data.equipment.active_hand

func set_active_set(number: int):
	if number == 0 or number == 1:
		data.equipment.active_set = number

func set_active_hand(number: int):
	if number == 0 or number == 1:
		data.equipment.active_hand = number

func get_equipment_slot(slot):
	return data.equipment.get(slot)

func get_weapon_slot(slot):
	return data.equipment.get_weapon_slot(slot)

func equip_item(slot, item):
	remove_conditions_from_equipment()
	if slot == "body":
		remove_item_from_slot(slot)
		data.equipment.body = item

	else:
		if data.equipment.get_weapon_slot(slot):
			remove_item_from_slot(slot)
		data.equipment.set_weapon_slot(slot, item)

	apply_conditions_from_equipment()
	if Global.focus_char == self:
		SignalBus.update_inventory.emit()
	update_stats()

func unequip_slot(slot):
	remove_conditions_from_equipment()
	remove_item_from_slot(slot)
	apply_conditions_from_equipment()
	if Global.focus_char == self:
		SignalBus.update_inventory.emit()
	update_stats()

func remove_item_from_slot(slot):
	var item = data.equipment.remove_item_from_slot(slot)
	return item

func take_damage(damage: int, resistance: String = ""):
	var value = get_stat(resistance)
	var resistance_value: int = value if value is int else 0
	var final_damage = (damage - resistance_value)
	if final_damage < 0:
		final_damage = 0
	change_stat("current_hp", -final_damage)
	var current_hp = get_stat("current_hp") 
	var max_hp = get_stat("max_hp") 
	if current_hp <= -max_hp:
		change_stat("current_hp", -max_hp)
	health_bar_instance.update_hp_bar()
	SignalBus.dialog_damage_taken.emit(data.name, final_damage)

func take_healing(healing: int):
	change_stat("current_hp", healing)
	var current_hp = get_stat("current_hp") 
	var max_hp = get_stat("max_hp") 
	if current_hp >= max_hp:
		set_stat("current_hp", max_hp)
	health_bar_instance.update_hp_bar()
	SignalBus.dialog_healing_taken.emit(data.name, healing)

func perceive_level():
	return data.level

func perceive_armour():
	return data.equipment.body

func perceive_health():
	return (data.current_hp + data.current_extra_hp)

func get_current_ap():
	return data.current_ap

func consume_ap(number):
	data.current_ap -= number
	if data.current_ap < 0:
		data.current_ap = 0

func meets_brawn_requirements() -> bool:
	var weapons = get_active_weapons()
	var main_hand = weapons[0]
	var off_hand = weapons[1]
	var brawn = get_stat("brawn")
	if brawn >= main_hand.brawn_req_1h:
		return true
	if brawn >= main_hand.brawn_req_2h and off_hand == data.equipment.default_weapon:
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
	print("_perform_attack_activity called.")
	var weapons = get_active_weapons()
	var category = data.equipment.get_active_attack_category()
	if weapons[0]:
		if category == 0 and weapons[0].strike:
			var attack_activity = weapons[0].strike.duplicate(true)
			attack_activity.weapon = weapons[0]
			perform_activity(attack_activity, target)
		elif category == 1 and weapons[0].shoot:
			var attack_activity = weapons[0].shoot.duplicate(true)
			attack_activity.weapon = weapons[0]
			perform_activity(attack_activity, target)
		elif category == 2 and weapons[0].throw:
			var attack_activity = weapons[0].throw.duplicate(true)
			attack_activity.weapon = weapons[0]
			perform_activity(attack_activity, target)

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

func senses_check_on_tile(target_tile) -> bool: 
	var origin_tile = Vector3i(data.tile_x, data.tile_y, data.tile_z)
	if _hearing_check(origin_tile, target_tile):
		return true
	if _sight_check(origin_tile, target_tile):
		return true
	return false

func discover_creature(creature):
	var id = creature.data.id

	if not data.relationships._tactical_map.has(id):
		var entry = TacticalRelationEntry.new()
		entry.target_id = id
		entry.last_updated_turn = Global.crisis_manager.crisis_turn
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

func build_tactical_map():
	data.relationships.build_tactical_map()

func get_tactical(target_id: int) -> TacticalRelationEntry:
	return data.relationships.get_tactical(target_id)

func set_hostile(target_id: int, value: int):
	data.relationships.set_hostile(target_id, value)

## This initalises the base stats, meant to be used on spawn and at every level-up, and not accessed from outside the class
func initialise():
	if not data.has_been_initialized:
		if data.id == 0:
			data.id = Global.id_manager.next_id()

		_duplicate_runtime_resources()
		data.derived_stats = DerivedStats.new()

		data.relationships = _ensure_resource(data.relationships, func(): return Relationships.new())
		data.attributes     = _ensure_resource(data.attributes, func(): return Attributes.new())
		data.base_stats     = _ensure_resource(data.base_stats, func(): return BaseStats.new())
		data.inventory      = _ensure_resource(data.inventory, func(): return Inventory.new())
		data.equipment      = _ensure_resource(data.equipment, func(): return Equipment.new())
		data.resistances    = _ensure_resource(data.resistances, func(): return Resistances.new())

		@warning_ignore("integer_division")
		data.base_stats.level_mod = data.level / 2
		data.base_stats.agility = data.attributes.dexterity + data.base_stats.level_mod
		data.base_stats.resolve = data.attributes.will + data.base_stats.level_mod
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
		data.base_stats.max_pp = data.attributes.will * data.base_stats.level_mod
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

		data.has_been_initialized = true
		update_stats()
		print("character file ready.")

## This builds the final usable stats; to be used directly for activities and from outside the class
func update_stats():
	if not stats_dirty:
		return
	data.derived_stats.agility = data.base_stats.agility + data.derived_stats.vigour
	data.derived_stats.resolve = data.base_stats.resolve + data.derived_stats.vigour
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
	data.derived_stats.max_spell_rank = data.base_stats.max_spell_rank
	
	stats_dirty = false
	sprite_node.texture = load(data.sprite)
	build_tactical_map()

func _on_start_crisis():
	update_stats()
	data.current_ap = data.derived_stats.max_ap
	data.current_mp = 0

func _on_end_turn():
	data.current_ap = data.derived_stats.max_ap
	data.current_mp = 0
	if not data.player_controlled:
		Global.focus_char = self
		ai_controller.crisisai.plan_turn() 

func _sight_check(origin_tile, target_tile) -> bool: 
	if WorldMath.pos_in_range_weighted_3d(origin_tile, target_tile, (data.base_stats.sense * 4)):
		if WorldMath.has_line_of_sight_tile(origin_tile, target_tile):
			return true
	return false

func _hearing_check(origin_tile, target_tile) -> bool: 
	if WorldMath.pos_in_range_weighted_3d(origin_tile, target_tile, (data.base_stats.sense * 1)):
		return true
	return false

func _ensure_resource(res: Resource, ctor: Callable) -> Resource:
	if res:
		return res.duplicate(true)
	return ctor.call()

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

func _ready():
	if not health_bar_scene:
		print("Health bar scene not set!")
		return
	health_bar_instance = health_bar_scene.instantiate()
	add_child(health_bar_instance)
	SignalBus.on_start_crisis.connect(_on_start_crisis)
	SignalBus.turn_ends.connect(_on_end_turn)
