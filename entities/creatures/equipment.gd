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

@export var slots: Dictionary[Enums.EquipmentSlot, ItemContainer] = {
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


func get_all_equipped_items() -> Array[ItemContainer]:
	var collection: Array[ItemContainer] = []
	for slot in slots:
		var container: ItemContainer = slots[slot]
		if container != null:
			collection.append(container)
	return collection


func get_active_weapon() -> ItemContainer:
	var weapons: Array[ItemContainer] = get_items_of_slot_type(Enums.SlotType.NONE)
	var selected_weapon: ItemContainer = weapons[active_hand]
	return selected_weapon


func equip_item(item_container: ItemContainer) -> bool:
	if item_container == null or item_container.item == null:
		return false

	var slot_array: Array = _get_slot_array(item_container.item.slot_type)
	if slot_array.is_empty():
		return false

	for slot in slot_array:
		if slots[slot] == null:
			slots[slot] = item_container
			return true

	return false


func equip_item_in_slot(item_container: ItemContainer, slot: Enums.EquipmentSlot) -> bool:
	if item_container == null or item_container.item == null:
		return false

	if not slots.has(slot):
		return false

	if slots[slot] != null:
		return false

	var slot_type: Enums.SlotType = SLOT_TO_TYPE[slot]

	if slot_type != Enums.SlotType.NONE and slot_type != item_container.item.slot_type:
		return false

	slots[slot] = item_container
	return true


func remove_item(item_or_container) -> ItemContainer:
	var target_item: Item = item_or_container.item if item_or_container is ItemContainer else (item_or_container as Item)
	if target_item == null:
		return null
	var item_id: String = target_item.id
	for slot in slots:
		var container: ItemContainer = slots[slot]
		if container and container.item and container.item.id == item_id:
			slots[slot] = null
			return container
	return null


func free_slot(slot: Enums.EquipmentSlot) -> ItemContainer:
	if not slots.has(slot):
		return null

	var container: ItemContainer = slots[slot]
	slots[slot] = null
	return container


func free_slot_type(slot_type: Enums.SlotType) -> Array[ItemContainer]:
	var items: Array[ItemContainer] = []
	var slot_array: Array = _get_slot_array(slot_type)

	for slot in slot_array:
		var container: ItemContainer = slots[slot]
		if container != null:
			items.append(container)
			slots[slot] = null

	return items


func get_item(item_or_container) -> ItemContainer:
	var target_item: Item = item_or_container.item if item_or_container is ItemContainer else (item_or_container as Item)
	for slot in slots:
		var container: ItemContainer = slots[slot]
		if container and (container == item_or_container or container.item == target_item):
			return container
	return null


func get_item_in_slot(slot: Enums.EquipmentSlot) -> ItemContainer:
	return slots.get(slot)


func get_items_of_slot_type(slot_type: Enums.SlotType) -> Array[ItemContainer]:
	var result: Array[ItemContainer] = []
	var slot_array: Array = _get_slot_array(slot_type)

	for slot in slot_array:
		var container: ItemContainer = slots[slot]
		if container != null:
			result.append(container)
		elif container == null: 
			if slot == Enums.EquipmentSlot.HAND_LEFT or slot == Enums.EquipmentSlot.HAND_RIGHT:
				result.append(slots[Enums.EquipmentSlot.HAND_DEFAULT])

	return result


func _get_slot_array(slot_type: Enums.SlotType) -> Array:
	return SLOT_TYPE_TO_SLOTS.get(slot_type, [])


func find_slot_of_item(item_or_container):
	var target_item: Item = item_or_container.item if item_or_container is ItemContainer else (item_or_container as Item)
	for slot in slots:
		var container: ItemContainer = slots[slot]
		if container and (container == item_or_container or container.item == target_item):
			return slot
	return null


func activate_hand_set(index: int) -> void:
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


func _equip_hand(slot: Enums.EquipmentSlot, item_or_container) -> void:
	if item_or_container == null:
		slots[slot] = slots[Enums.EquipmentSlot.HAND_DEFAULT]
		return

	if item_or_container is ItemContainer:
		slots[slot] = item_or_container
	elif item_or_container is Item:
		slots[slot] = ItemContainer.new(item_or_container, 1)
