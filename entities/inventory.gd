extends Resource
class_name Inventory

@export var list: Array[ItemContainer] = []


func get_inventory() -> Array[ItemContainer]:
	return list


func has_item(item: Item) -> bool:
	if item == null:
		return false
	for container: ItemContainer in list:
		if container.item == item or container.item.id == item.id:
			return true
	return false


func has_container(container: ItemContainer) -> bool:
	return list.has(container)


func remove_from_inventory(item_or_container) -> void:
	if item_or_container is ItemContainer:
		list.erase(item_or_container)
	elif item_or_container is Item:
		for container: ItemContainer in list:
			if container.item == item_or_container or container.item.id == item_or_container.id:
				list.erase(container)
				return


func add_item(item: Item, amount: int = 1) -> ItemContainer:
	if item == null or amount <= 0:
		return null
	item.owner = self
	for container: ItemContainer in list:
		if container.can_stack_with(item):
			container.amount += amount
			return container
	var new_container: ItemContainer = ItemContainer.new(item, amount)
	list.append(new_container)
	return new_container


func add_container(container: ItemContainer) -> ItemContainer:
	if container == null or container.item == null or container.amount <= 0:
		return null
	container.item.owner = self
	for existing: ItemContainer in list:
		if existing.can_stack_with_container(container):
			existing.amount += container.amount
			return existing
	list.append(container)
	return container


func add_item_container(container: ItemContainer) -> ItemContainer:
	return add_container(container)


func add_item_at_index(item: Item, index: int, amount: int = 1) -> ItemContainer:
	if item == null or amount <= 0:
		return null
	item.owner = self
	for container: ItemContainer in list:
		if container.can_stack_with(item):
			container.amount += amount
			return container
	var new_container: ItemContainer = ItemContainer.new(item, amount)
	var target_index: int = clampi(index, 0, list.size())
	list.insert(target_index, new_container)
	return new_container


func add_container_at_index(container: ItemContainer, index: int) -> ItemContainer:
	if container == null or container.item == null or container.amount <= 0:
		return null
	container.item.owner = self
	for existing: ItemContainer in list:
		if existing.can_stack_with_container(container):
			existing.amount += container.amount
			return existing
	var target_index: int = clampi(index, 0, list.size())
	list.insert(target_index, container)
	return container


func add_item_container_at_index(container: ItemContainer, index: int) -> ItemContainer:
	return add_container_at_index(container, index)


func remove_item(item: Item, amount: int = 1) -> Item:
	if item == null or amount <= 0:
		return null
	for container: ItemContainer in list:
		if container.item == item or container.item.id == item.id:
			if container.amount > amount:
				container.amount -= amount
				return container.item
			else:
				list.erase(container)
				return container.item
	return null


func remove_container(container: ItemContainer) -> ItemContainer:
	if container == null:
		return null
	if list.has(container):
		list.erase(container)
		return container
	return null


func remove_item_at_index(index: int, amount: int = 1) -> ItemContainer:
	if index < 0 or index >= list.size():
		return null
	var container: ItemContainer = list[index]
	if container.amount > amount:
		container.amount -= amount
		var new_container: ItemContainer = ItemContainer.new(container.item, amount)
		return new_container
	else:
		list.remove_at(index)
		return container
