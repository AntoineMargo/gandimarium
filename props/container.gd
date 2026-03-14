extends Prop
class_name ContainerProp

@export var inventory: Inventory = null

func make_delta() -> PropDelta:
	var prop_delta = PropDelta.new()
	prop_delta.id = id
	prop_delta.pos = pos
	prop_delta.hp = current_hp
	if inventory:
		prop_delta.inventory = inventory.list
	return prop_delta

func operate(_creature: Creature):
	SignalBus.update_container.emit(self)
	if Global.container_window.visible == false:
		Global.container_window.visible = true
	else:
		Global.container_window.visible = false

func _initalize_container():
	inventory = Inventory.new()
	var new_item = Library.get_item("food_bread")
	new_item = new_item.duplicate(true)
	new_item.count = 10
	inventory.list.append(new_item)

func add_item_to_inventory(item: Item) -> void:
	item.owner = self
	inventory.add_item(item)
	SignalBus.update_container.emit()

func remove_item(item: Item) -> Item:
	if item in inventory.list:
		inventory.remove_from_inventory(item)
		return item
	return null

func _ready() -> void:
	_on_ready()
	_initalize_container()
