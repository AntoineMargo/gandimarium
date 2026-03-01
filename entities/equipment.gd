extends Resource
class_name Equipment

const SLOT_MAP = {
	"set1_left_hand":  Vector2i(0, 0),
	"set1_right_hand": Vector2i(0, 1),
	"set2_left_hand":  Vector2i(1, 0),
	"set2_right_hand": Vector2i(1, 1),
}

@export var head: Item
@export var shoulders: Item
@export var neck: Item
@export var body: Item
@export var armour: Item
@export var belt: Item
@export var gauntlets: Item
@export var boots: Item
@export var left_wrist: Item
@export var right_wrist: Item
@export var left_ring: Item
@export var right_ring: Item

@export var default_weapon: Item

@export var weapon_sets := [
	[null, null],
	[null, null]
]

@export var strike_types := [
	[0, 0],
	[0, 0]
]

var shoot_types := [0, 0]  # usually irrelevant
var throw_types := [0, 0]  # usually irrelevant

var active_set: int = 0
var active_hand: int = 0
var active_category: int = 0

func get_active_weapon():
	return weapon_sets[active_set][active_hand]

func get_active_set_weapons():
	var left_weapon = null
	var right_weapon = null
	if active_set == 0:
		left_weapon = weapon_sets[0][0]
		right_weapon = weapon_sets[0][1]
	else:
		left_weapon = weapon_sets[1][0]
		right_weapon = weapon_sets[1][1]
	if not left_weapon:
		left_weapon = default_weapon
	if not right_weapon:
		right_weapon = default_weapon
	return [left_weapon, right_weapon]

func get_active_weapons():
	var weapons = [weapon_sets[active_set][active_hand], weapon_sets[active_set][1 - active_hand]]
	if not weapons[0]:
		weapons[0] = default_weapon
	if not weapons[1]:
		weapons[1] = default_weapon
	return weapons

func get_active_strike_type():
	return strike_types[active_set][active_hand]

func get_active_shoot_type():
	return shoot_types[active_hand]

func get_active_throw_type():
	return throw_types[active_hand]

func get_active_attack_category():
	return active_category

func set_active_strike_type(hand, type):
	strike_types[active_set][hand] = type

func set_active_attack_category(number):
	if number >= 0 and number <= 2:
		active_category = number

func get_equipment_slot(slot):
	var weap_pos = SLOT_MAP.get(slot)
	if weap_pos:
		return weapon_sets[weap_pos.x][weap_pos.y] if not null else default_weapon
	return get(slot)

func get_weapon_slot(slot):
	var pos = SLOT_MAP.get(slot)
	var item = weapon_sets[pos.x][pos.y]
	if item:
		return item
	else:
		return default_weapon

func set_weapon_slot(slot, item):
	var pos = SLOT_MAP.get(slot)
	weapon_sets[pos.x][pos.y] = item
	if item:
		if item.strike:
			if item.strike.attack_types.size() > 0:
				strike_types[pos.x][pos.y] = item.strike.attack_types[0].id
		if active_set == pos.x:
			if item.shoot:
				shoot_types[pos.y] = item.shoot.attack_types[0].id
			if item.throw:
				throw_types[pos.y] = item.throw.attack_types[0].id

func get_all_equipped_items():
	var collection = []
	for item in weapon_sets[active_set]:
		if item:
			collection.append(item)
	if body:
		collection.append(body)
	# Others...
	return collection

func remove_item_from_slot(slot):
	var item: Item = null
	if slot == "body":
		if body:
			item = body
			body = null
	else:
		item = get_weapon_slot(slot)
		set_weapon_slot(slot, null)
	return (item)

#func remove_item_from_slot(slot):
	#var item: Item = null
	#if slot == "body":
		#if body:
			#item = body
			#body = null
	#else:
		#item = get_weapon_slot(slot)
		#var fist = Library.get_item("wpn_fist")
		#set_weapon_slot(slot, fist)
	#return (item)
