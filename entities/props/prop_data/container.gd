extends PropData
class_name PropDataContainer

@export var inventory: Inventory = null


func operate(_creature: Creature):
	SignalBus.update_container.emit(self)
	if Global.game_session.container_window.visible == false:
		Global.game_session.container_window.visible = true
	else:
		Global.game_session.container_window.visible = false

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

#func _ready() -> void:
	#_on_ready()
	#_initalize_container()
