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
	var item_id = item.id
	#var item_uid = item.uid
	for slot in slots:
		if slots[slot] and slots[slot].id == item_id:
			slots[slot] = null
			return item
	return null


#func remove_item(item: Item) -> Item:
	#for slot in slots:
		#if slots[slot] == item:
			#slots[slot] = null
			#return item
	#return null

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
