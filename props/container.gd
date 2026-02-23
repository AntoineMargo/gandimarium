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
