extends Prop
class_name ContainerProp

#@export var default_inventory: Array[Item] = [
	#Library.get_item("wpn_bow"),
	#Library.get_item("wpn_bow"),
	#Library.get_item("wpn_bow"),
	#Library.get_item("wpn_bow"),
	#Library.get_item("wpn_bow"),
	#Library.get_item("wpn_bow")
	#]

@export var default_inventory: Array[Item] = []

var runtime_inventory = []

func get_inventory():
	return runtime_inventory

func add_item(item: Item):
	var inventory = runtime_inventory
	item = item.duplicate(true)

	for element in inventory:
		if element.id == item.id:
			#element.count += item.count
			element.count += 1
			return
	inventory.append(item)

func add_item_at_index(item: Item, index: int):
	var inventory = runtime_inventory
	for element in inventory:
		if element.id == item.id:
			#element.count += item.count
			element.count += 1
			return
	item = item.duplicate(true)
	inventory.insert(index, item)

func remove_item(item: Item):
	var inventory = runtime_inventory
	for element in inventory:
		if element.id == item.id:
			if element.count > 1:
				element.count -= 1
				var new_item = item.duplicate(true)
				new_item.count = 1
				return new_item
			else:
				inventory.erase(element)
				return item

func remove_item_at_index(index: int):
	var inventory = runtime_inventory
	var item = inventory[index]

	if item.count > 1:
		item.count -= 1
		var new_item = item.duplicate(true)
		new_item.count = 1
		return new_item
	else:
		inventory.remove_at(index)
		return item

func make_delta() -> PropDelta:
	var prop_delta = PropDelta.new()
	prop_delta.id = id
	prop_delta.pos = pos
	prop_delta.hp = current_hp
	prop_delta.inventory = runtime_inventory
	return prop_delta

func operate():
	SignalBus.update_container.emit(self)
	if Global.container_window.visible == false:
		Global.container_window.visible = true
	else:
		Global.container_window.visible = false

func _initalize_container():
	if runtime_inventory.is_empty():
		var new_item = Library.get_item("wpn_bow")
		new_item = new_item.duplicate(true)
		new_item.count = 5
		runtime_inventory = default_inventory.duplicate(true)
		runtime_inventory.append(new_item)

func _ready() -> void:
	_on_ready()
	_initalize_container()
