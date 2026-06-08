extends Resource
class_name Equipment

const HAND_SLOTS = [
	Enums.EquipmentSlot.HAND_LEFT,
	Enums.EquipmentSlot.HAND_RIGHT
]

const RING_SLOTS = [
	Enums.EquipmentSlot.RING1,
	Enums.EquipmentSlot.RING2,
	Enums.EquipmentSlot.RING3,
	Enums.EquipmentSlot.RING4,
	Enums.EquipmentSlot.RING5,
	Enums.EquipmentSlot.RING6
]

const SLOT_TYPE_TO_SLOTS = {
	Enums.SlotType.HELM: [
		Enums.EquipmentSlot.HELM
	],
	Enums.SlotType.CAPE: [
		Enums.EquipmentSlot.CAPE
	],
	Enums.SlotType.ARMOUR: [
		Enums.EquipmentSlot.ARMOUR
	],
	Enums.SlotType.TOP: [
		Enums.EquipmentSlot.TOP
	],
	Enums.SlotType.BELT: [
		Enums.EquipmentSlot.BELT
	],
	Enums.SlotType.BOTTOM: [
		Enums.EquipmentSlot.BOTTOM
	],
	Enums.SlotType.GAUNTLETS: [
		Enums.EquipmentSlot.GAUNTLETS
	],
	Enums.SlotType.SHOES: [
		Enums.EquipmentSlot.SHOES
	],
	Enums.SlotType.NECKLACE: [
		Enums.EquipmentSlot.NECKLACE
	],
	Enums.SlotType.RING: [
		Enums.EquipmentSlot.RING1,
		Enums.EquipmentSlot.RING2,
		Enums.EquipmentSlot.RING3,
		Enums.EquipmentSlot.RING4,
		Enums.EquipmentSlot.RING5,
		Enums.EquipmentSlot.RING6
	],
	Enums.SlotType.BRACER: [
		Enums.EquipmentSlot.BRACER_LEFT,
		Enums.EquipmentSlot.BRACER_RIGHT
	],
	Enums.SlotType.NONE: [
		Enums.EquipmentSlot.HAND_LEFT,
		Enums.EquipmentSlot.HAND_RIGHT
	]
}

const SLOT_TO_TYPE = {
	Enums.EquipmentSlot.HELM: Enums.SlotType.HELM,
	Enums.EquipmentSlot.CAPE: Enums.SlotType.CAPE,
	Enums.EquipmentSlot.ARMOUR: Enums.SlotType.ARMOUR,
	Enums.EquipmentSlot.TOP: Enums.SlotType.TOP,
	Enums.EquipmentSlot.BELT: Enums.SlotType.BELT,
	Enums.EquipmentSlot.BOTTOM: Enums.SlotType.BOTTOM,
	Enums.EquipmentSlot.GAUNTLETS: Enums.SlotType.GAUNTLETS,
	Enums.EquipmentSlot.SHOES: Enums.SlotType.SHOES,
	Enums.EquipmentSlot.NECKLACE: Enums.SlotType.NECKLACE,

	Enums.EquipmentSlot.RING1: Enums.SlotType.RING,
	Enums.EquipmentSlot.RING2: Enums.SlotType.RING,
	Enums.EquipmentSlot.RING3: Enums.SlotType.RING,
	Enums.EquipmentSlot.RING4: Enums.SlotType.RING,
	Enums.EquipmentSlot.RING5: Enums.SlotType.RING,
	Enums.EquipmentSlot.RING6: Enums.SlotType.RING,

	Enums.EquipmentSlot.BRACER_LEFT: Enums.SlotType.BRACER,
	Enums.EquipmentSlot.BRACER_RIGHT: Enums.SlotType.BRACER,

	Enums.EquipmentSlot.HAND_LEFT: Enums.SlotType.NONE,
	Enums.EquipmentSlot.HAND_RIGHT: Enums.SlotType.NONE,
	Enums.EquipmentSlot.HAND_DEFAULT: Enums.SlotType.NONE,
}

@export var slots: Dictionary[Enums.EquipmentSlot, Item] = {
	Enums.EquipmentSlot.HELM: null,
	Enums.EquipmentSlot.CAPE: null,
	Enums.EquipmentSlot.ARMOUR: null,
	Enums.EquipmentSlot.TOP: null,
	Enums.EquipmentSlot.BELT: null,
	Enums.EquipmentSlot.BOTTOM: null,
	Enums.EquipmentSlot.GAUNTLETS: null,
	Enums.EquipmentSlot.SHOES: null,
	Enums.EquipmentSlot.NECKLACE: null,
	Enums.EquipmentSlot.RING1: null,
	Enums.EquipmentSlot.RING2: null,
	Enums.EquipmentSlot.RING3: null,
	Enums.EquipmentSlot.RING4: null,
	Enums.EquipmentSlot.RING5: null,
	Enums.EquipmentSlot.RING6: null,
	Enums.EquipmentSlot.BRACER_LEFT: null,
	Enums.EquipmentSlot.BRACER_RIGHT: null,
	Enums.EquipmentSlot.HAND_LEFT: null,
	Enums.EquipmentSlot.HAND_RIGHT: null,
	Enums.EquipmentSlot.HAND_DEFAULT: null
}

@export var hand_sets: Array[HandSet] = []
@export var active_hand_set: int = 0

@export var active_hand: int = 0
@export var active_category: Enums.AttackCategory = Enums.AttackCategory.STRIKE

func get_all_equipped_items() -> Array[Item]:
	var collection: Array[Item] = []
	for slot in slots:
		var item: Item = slots[slot]
		if item != null:
			collection.append(item)
	return collection

func get_active_weapon() -> Item:
	var weapons = get_items_of_slot_type(Enums.SlotType.NONE)
	var selected_weapon = weapons[active_hand]
	return selected_weapon

func equip_item(item: Item) -> bool:
	if item == null:
		return false

	var slot_array = _get_slot_array(item.slot_type)
	if slot_array.is_empty():
		return false

	for slot in slot_array:
		if slots[slot] == null:
			slots[slot] = item
			return true

	return false

func equip_item_in_slot(item: Item, slot: Enums.EquipmentSlot) -> bool:
	if item == null:
		return false

	if not slots.has(slot):
		return false

	if slots[slot] != null:
		return false

	var slot_type = SLOT_TO_TYPE[slot]

	if slot_type != Enums.SlotType.NONE and slot_type != item.slot_type:
		return false

	slots[slot] = item
	return true

func remove_item(item: Item) -> Item:
	for slot in slots:
		if slots[slot] == item:
			slots[slot] = null
			return item
	return null

func free_slot(slot: Enums.EquipmentSlot) -> Item:
	if not slots.has(slot):
		return null

	var item: Item = slots[slot]
	slots[slot] = null
	return item

func free_slot_type(slot_type: Enums.SlotType) -> Array[Item]:
	var items: Array[Item] = []
	var slot_array = _get_slot_array(slot_type)

	for slot in slot_array:
		var item: Item = slots[slot]
		if item != null:
			items.append(item)
			slots[slot] = null

	return items

func get_item(item: Item) -> Item:
	for slot in slots:
		if slots[slot] == item:
			return item
	return null

func get_item_in_slot(slot: Enums.EquipmentSlot) -> Item:
	return slots.get(slot)

func get_items_of_slot_type(slot_type: Enums.SlotType) -> Array[Item]:
	var result: Array[Item] = []
	var slot_array = _get_slot_array(slot_type)

	for slot in slot_array:
		var item: Item = slots[slot]
		if item != null:
			result.append(item)
		elif item == null: 
			if slot == Enums.EquipmentSlot.HAND_LEFT or slot == Enums.EquipmentSlot.HAND_RIGHT:
				result.append(slots[Enums.EquipmentSlot.HAND_DEFAULT])

	return result

func _get_slot_array(slot_type: Enums.SlotType) -> Array:
	return SLOT_TYPE_TO_SLOTS.get(slot_type, [])

## -> Enums.EquipmentSlot
func find_slot_of_item(item: Item):
	for slot in slots:
		if slots[slot] == item:
			return slot
	return null

func activate_hand_set(index: int):
	if index < 0 or index >= hand_sets.size():
		return

	active_hand_set = index
	var hand_set = hand_sets[index]

	if hand_set.left_hand != null:
		_equip_hand(Enums.EquipmentSlot.HAND_LEFT, hand_set.left_hand)

	if hand_set.right_hand != null:
		_equip_hand(Enums.EquipmentSlot.HAND_RIGHT, hand_set.right_hand)

func has_slot(slot: Enums.EquipmentSlot) -> bool:
	if not slots.has(slot):
		return false
	return true

func _equip_hand(slot: Enums.EquipmentSlot, item: Item):
	if item == null:
		slots[slot] = slots[Enums.EquipmentSlot.HAND_DEFAULT]
		return

	#if item.slot_type != Enums.SlotType.NONE:
		#return

	slots[slot] = item



#@export var head: Item
#@export var shoulders: Item
#@export var neck: Item
#@export var body: Item
#@export var armour: Item
#@export var belt: Item
#@export var gauntlets: Item
#@export var boots: Item
#@export var left_wrist: Item
#@export var right_wrist: Item
#@export var left_ring: Item
#@export var right_ring: Item
#
#@export var default_weapon: Item

#@export var weapon_sets = [
	#[null, null],
	#[null, null]
#]

#@export var strike_types = [
	#[0, 0],
	#[0, 0]
#]
#
#var shoot_types = [0, 0]  # usually irrelevant
#var throw_types = [0, 0]  # usually irrelevant
#
#var active_set: int = 0
#var active_hand: int = 0
#var active_category: int = 0

#func equip(item: Item) -> bool:
	#var slot_type = item.slot_type
	#var possible_slots = SLOT_TYPE_TO_SLOTS.get(slot_type, [])
#
	#for slot in possible_slots:
		#if slots[slot] == null:
			#slots[slot] = item
			#return true
#
	#return false
#
#func get_active_weapon():
	#return weapon_sets[active_set][active_hand]
#
#func get_active_set_weapons():
	#var left_weapon = null
	#var right_weapon = null
	#if active_set == 0:
		#left_weapon = weapon_sets[0][0]
		#right_weapon = weapon_sets[0][1]
	#else:
		#left_weapon = weapon_sets[1][0]
		#right_weapon = weapon_sets[1][1]
	#if not left_weapon:
		#left_weapon = default_weapon
	#if not right_weapon:
		#right_weapon = default_weapon
	#return [left_weapon, right_weapon]
#
#func get_active_weapons():
	#var weapons = [weapon_sets[active_set][active_hand], weapon_sets[active_set][1 - active_hand]]
	#if not weapons[0]:
		#weapons[0] = default_weapon
	#if not weapons[1]:
		#weapons[1] = default_weapon
	#return weapons
#
#func get_active_strike_type():
	#return strike_types[active_set][active_hand]
#
#func get_active_shoot_type():
	#return shoot_types[active_hand]
#
#func get_active_throw_type():
	#return throw_types[active_hand]
#
#func get_active_attack_category():
	#return active_category
#
#func set_active_strike_type(hand, type):
	#strike_types[active_set][hand] = type
#
#func set_active_attack_category(number):
	#if number >= 0 and number <= 2:
		#active_category = number
#
#func get_equipment_slot(slot):
	#var weap_pos = SLOT_MAP.get(slot)
	#if weap_pos:
		#return weapon_sets[weap_pos.x][weap_pos.y] if not null else default_weapon
	#return get(slot)
#
#func get_weapon_slot(slot):
	#var pos = SLOT_MAP.get(slot)
	#var item = weapon_sets[pos.x][pos.y]
	#if item:
		#return item
	#else:
		#return default_weapon
#
#func set_weapon_slot(slot, item):
	#var pos = SLOT_MAP.get(slot)
	#weapon_sets[pos.x][pos.y] = item
	#if item:
		#if item.strike:
			#if item.strike.attack_types.size() > 0:
				#strike_types[pos.x][pos.y] = item.strike.attack_types[0].id
		#if active_set == pos.x:
			#if item.shoot:
				#shoot_types[pos.y] = item.shoot.attack_types[0].id
			#if item.throw:
				#throw_types[pos.y] = item.throw.attack_types[0].id
#
#func get_all_equipped_items() -> Array:
	#var collection = []
	#for item in weapon_sets[active_set]:
		#if item:
			#collection.append(item)
	#if body:
		#collection.append(body)
	## Others...
	#return collection
#
#func remove_item_from_slot(slot):
	#var item: Item = null
	#if slot == "body":
		#if body:
			#item = body
			#body = null
	#else:
		#item = get_weapon_slot(slot)
		#set_weapon_slot(slot, null)
	#return (item)
#
#func remove_item(item: Item) -> Item:
	#if get("body") == item:
		#set("body", null)
		#item.owner = null
		#return item
	#return null
