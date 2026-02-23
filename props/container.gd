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

func operate():
	SignalBus.update_container.emit(self)
	if Global.container_window.visible == false:
		Global.container_window.visible = true
	else:
		Global.container_window.visible = false

func _initalize_container():
	inventory = Inventory.new()
	var new_item = Library.get_item("wpn_bow")
	new_item = new_item.duplicate(true)
	new_item.count = 5
	inventory.list.append(new_item)

func _ready() -> void:
	_on_ready()
	_initalize_container()
