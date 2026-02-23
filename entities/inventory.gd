extends Resource
class_name Inventory

@export var list: Array = []

func get_inventory():
	return list

func add_to_inventory(item):
	list.append(item)

func remove_from_inventory(item):
	list.erase(item)

func add_item(item: Item):
	var inventory = list
	item = item.duplicate(true)

	for element in inventory:
		if element.id == item.id:
			element.count += item.count
			return
	inventory.append(item)

func add_item_at_index(item: Item, index: int):
	var inventory = list
	for element in inventory:
		if element.id == item.id:
			element.count += item.count
			return
	item = item.duplicate(true)
	inventory.insert(index, item)

func remove_item(item: Item):
	var inventory = list
	for element in inventory:
		if element.id == item.id:
			inventory.erase(element)
			return item

func remove_item_at_index(index: int):
	var inventory = list
	var item = inventory[index]

	if item.count > 1:
		item.count -= 1
		var new_item = item.duplicate(true)
		new_item.count = 1
		return new_item
	else:
		inventory.remove_at(index)
		return item
