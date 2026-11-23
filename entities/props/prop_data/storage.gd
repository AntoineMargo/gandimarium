extends PropData
class_name PropDataStorage

@export var inventory: Inventory = null


func operate(_creature: Creature):
	SignalBus.update_container.emit(self)
	if Global.game_session.container_window.visible == false:
		Global.game_session.container_window.visible = true
	else:
		Global.game_session.container_window.visible = false

func setup():
	inventory = Inventory.new()
	var item: Item = Library.get_item("food_bread")
	var item_container: ItemContainer = ItemContainer.new(item, 10)
	inventory.add_container(item_container)


func add_item_to_inventory(item: Item) -> void:
	item.owner = self
	inventory.add_item(item)
	SignalBus.update_container.emit()


func remove_item(item: Item) -> Item:
	if item in inventory.list:
		inventory.remove_from_inventory(item)
		return item
	return null
