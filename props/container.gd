extends Prop
class_name ContainerProp

@export var default_inventory: Array[Item] = [
	Library.get_item("wpn_bow"),
	Library.get_item("wpn_bow"),
	Library.get_item("wpn_bow"),
	Library.get_item("wpn_bow"),
	Library.get_item("wpn_bow"),
	Library.get_item("wpn_bow")
	]

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
		runtime_inventory = default_inventory.duplicate(true)

func _ready() -> void:
	_on_ready()
	_initalize_container()
