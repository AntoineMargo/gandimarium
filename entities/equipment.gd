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
@export var belt: Item
@export var gauntlets: Item
@export var boots: Item
@export var left_wrist: Item
@export var right_wrist: Item
@export var head_item: Item
@export var left_ring: Item
@export var right_ring: Item

@export var weapon_sets := [
	[null, null],
	[null, null]
]

@export var attack_types := [
	[0, 0],
	[0, 0]
]

var active_set: int = 0
var active_hand: int = 0

func get_active_weapon():
	return weapon_sets[active_set][active_hand]

func get_active_weapons():
	#print("get_active_weapons function")
	#print("Active set: ", active_set)
	#print("Active hand: ", active_hand)
	#print("First: ", weapon_sets[active_set][active_hand])
	#print("Second: ", weapon_sets[active_set][1 - active_hand])
	return [weapon_sets[active_set][active_hand], weapon_sets[active_set][1 - active_hand]]

func get_active_attack_type():
	return attack_types[active_set][active_hand]

func get_weapon_slot(slot):
	var pos = SLOT_MAP.get(slot)
	return weapon_sets[pos.x][pos.y]

func set_weapon_slot(slot, item):
	var pos = SLOT_MAP.get(slot)
	weapon_sets[pos.x][pos.y] = item

func get_all_equipped_items():
	var collection = []
	for item in weapon_sets[active_set]:
		if item:
			collection.append(item)
	if body:
		collection.append(body)
	# Others...

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
