extends Resource

class_name CreatureData

@export var name: String
@export var level: int = 1
@export var sprite: String = "res://art/characters/swordwraith1.png"

@export var acuity: int = 5
@export var brawn: int = 5
@export var dexterity: int = 5
@export var will: int = 5

@export var base_size: String = "medium"
@export var final_size: String = "medium"

@export var talents: Array = []
@export var activities: Array = []
@export var spells_ready: Array = []
@export var spells_available: Array = []
@export var reactions: Array = []
@export var conditions: Array = []
@export var concentrations: Array = []
@export var inventory: Array = []

@export var head: Item
@export var shoulders: Item
@export var neck: Item
@export var body: Item
@export var belt: Item
@export var gauntlets: Item
@export var boots: Item
@export var left_wrist: Item
@export var right_wrist: Item
@export var head_item: Item
@export var left_ring: Item
@export var right_ring: Item
#@export var set1_left_hand: Item
#@export var set1_right_hand: Item
#@export var set2_left_hand: Item
#@export var set2_right_hand: Item
@export var weapon_sets := [
	[null, null],
	[null, null]
]

#var active_attack1: int = 0
#var active_attack2: int = 0
@export var attack_types := [
	[0, 0],
	[0, 0]
]

var active_set: int = 0
var active_hand: int = 0

# Derived values
var level_mod: int = 0

var agility: int = 0
var resolve: int = 0
var sense: int = 0
var stamina: int = 0
var offence: int = 0
var melee_defence: int = 0
var ranged_defence: int = 0

var strength_bonus: int = 0
var max_mp: int = 0
var current_mp: float = 0

var max_hp: int = 0
var current_hp: int = 0
var current_extra_hp: int = 0

var max_pp: int = 0
var current_pp: int = 0

var max_ep: int = 0
var current_ep: int = 0

var max_ap: int = 3
var current_ap: int = 3

var max_reactions: int = 1
var current_reactions: int = 1

var vigour: int = 0

var current_spell_rank: int = 0
var max_spell_rank: int = 0

var player_controlled: bool = false

var active_right_click: Activity

# Resistances
var physical_resist: int = 0
var heat_resist: int = 0
var cold_resist: int = 0
var electricity_resist: int = 0
var corrosion_resist: int = 0
var poison_resist: int = 0
var psychic_resist: int = 0

# Meta utility 
var creature: Creature
var reachable_tiles = []

# Tactical information
@export var map_id: String = ""
@export var map_layer_id: int = 0
@export var tile_x: int = 0
@export var tile_y: int = 0

@export var protective = []
@export var cooperative = []
@export var suspicious = []
@export var fearful = []
@export var hostile = []

var crisis_ai_active: bool = false

func _on_end_turn():
	current_ap = max_ap
	current_mp = 0

func add_activity(activity: Activity):
	if activity not in activities:
		activities.append(activity)

func add_ready_spell(spell: Spell):
	if spell not in spells_ready:
		spells_ready.append(spell)
	#spells_ready.append(spell)
	
func add_concentration(concentration: Concentration):
	concentrations.append(concentration)
	SignalBus.update_ui_for_char.emit()

func remove_concentration(concentration: Concentration):
	concentrations.erase(concentration)

func add_talent(talent: Talent):
	for weaker_talent in talent.supplanted:
		if has_talent_named(weaker_talent.name):
			remove_talent(weaker_talent)
	for existing_talent in talents:
		for weaker_talent in existing_talent.supplanted:
			if talent.name == weaker_talent.name:
				return
	talents.append(talent)

func remove_talent(talent: Condition):
	for existing_talent in talents:
		if existing_talent.name == talent.name:
			talents.erase(existing_talent)

func has_talent_named(talent_name: String) -> bool:
	for talent in talents:
		if talent.name == talent_name:
			return true
	return false

func has_condition_named(condition_name: String) -> bool:
	for condition in conditions:
		if condition.name == condition_name:
			return true
	return false

func apply_modifier(stat, value):
	if stat in self:
		self.set(stat, self.get(stat) + value)

func remove_modifier(stat, value):
	if stat in self:
		self.set(stat, self.get(stat) - value)

func add_condition(condition: Condition):
	if has_condition_named(condition.name):
		return
	for weaker_cond in condition.supplanted:
		if has_condition_named(weaker_cond.name):
			remove_condition(weaker_cond)
	for existing_cond in conditions:
		for weaker_cond in existing_cond.supplanted:
			if condition.name == weaker_cond.name:
				return
	conditions.append(condition)
	condition.initialize(self)
	#for effect in condition.effects:
		#effect.apply(self, self, -1)

func remove_condition(condition: Condition):
	for effect in condition.effects:
		effect.remove(self, self, -1)
	for existing_cond in conditions:
		if existing_cond.name == condition.name:
			conditions.erase(existing_cond)

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
		for i in range(conditions.size() - 1, -1, -1):
			var cond = conditions[i]
			if cond.name == item_condition.name:
				remove_condition(cond)

func get_active_weapon():
	return weapon_sets[active_set][active_hand]

func get_active_attack_type():
	return attack_types[active_set][active_hand]

func remove_conditions_from_equipment():
	for weapon in weapon_sets[active_set]:
			remove_item_conditions(weapon)

func apply_conditions_from_equipment():
	for weapon in weapon_sets[active_set]:
			add_item_conditions(weapon)
	#add_item_conditions(body)
	# all other slots...

func make_active_set(number):
	if number not in [0, 1]:
		return
	remove_conditions_from_equipment()
	active_set = number
	apply_conditions_from_equipment()

func make_active_hand(number):
	if number not in [0, 1]:
		return
	active_hand = number

func add_to_inventory(item):
	inventory.append(item)

func remove_from_inventory(item):
	inventory.erase(item)


const SLOT_MAP = {
	"set1_left_hand":  Vector2i(0, 0),
	"set1_right_hand": Vector2i(0, 1),
	"set2_left_hand":  Vector2i(1, 0),
	"set2_right_hand": Vector2i(1, 1),
}

func get_weapon_slot(slot):
	var pos = SLOT_MAP.get(slot)
	return weapon_sets[pos.x][pos.y]

func set_weapon_slot(slot, item):
	var pos = SLOT_MAP.get(slot)
	weapon_sets[pos.x][pos.y] = item

func equip_item(slot, item):
	remove_conditions_from_equipment()
	if slot == "body":
		_remove_item_from_slot(slot)
		body = item

	else:
		if get_weapon_slot(slot):
			_remove_item_from_slot(slot)
		set_weapon_slot(slot, item)

	apply_conditions_from_equipment()
	SignalBus.update_inventory.emit()

func unequip_slot(slot):
	remove_conditions_from_equipment()
	_remove_item_from_slot(slot)
	apply_conditions_from_equipment()
	
func _remove_item_from_slot(slot):
	if slot == "body":
		if body:
			add_to_inventory(slot)
			body = null
	else:
		add_to_inventory(get_weapon_slot(slot))
		set_weapon_slot(slot, null)

func take_damage(damage: int, resistance: String = ""):
	var resistance_value: int = 0
	if resistance != "":
		for prop in get_property_list():
			if prop.name == resistance:
				resistance_value = get(resistance)
				break
	var final_damage = (damage - resistance_value)
	if final_damage < 0:
		final_damage = 0
	current_hp -= final_damage
	if current_hp <= -max_hp:
		current_hp = -max_hp
	creature.health_bar_instance.update_hp_bar()
	#SignalBus.dialog_damage_taken.emit(name, final_damage)

func take_healing(healing: int):
	current_hp += healing
	if current_hp >= max_hp:
		current_hp = max_hp
	creature.health_bar_instance.update_hp_bar()
	SignalBus.dialog_healing_taken.emit(name, healing)

func perceive_level():
	return level

func perceive_health():
	return (current_hp + current_extra_hp)

func initialise():
	level_mod = level / 2
	agility = dexterity + level_mod
	resolve = will + level_mod
	sense = acuity + level_mod
	stamina = brawn + level_mod
	offence = acuity + level_mod
	melee_defence = dexterity + level_mod
	ranged_defence = dexterity + level_mod

	strength_bonus = brawn
	max_mp = dexterity
	current_mp = 0.0
	
	max_hp = (brawn * 12) + (brawn * level_mod)
	current_hp = max_hp
	current_extra_hp = 0

	max_ep = (brawn * 12) + (brawn * level_mod)
	current_ep = max_ep

	current_ap = max_ap
	current_reactions = max_reactions
	
	active_hand = 1
	
	SignalBus.turn_ends.connect(_on_end_turn)
	print("character file ready.")
