extends Resource

class_name Inventory

@export var list: Array = []

func get_inventory():
	return list

func add_to_inventory(item):
	list.append(item)

func remove_from_inventory(item):
	list.erase(item)
