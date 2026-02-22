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
	SignalBus.dialog_show_message.emit("Opening container.")
	#Global.container_window.update_items(self)
	SignalBus.update_container.emit(self)
	Global.container_window.visible = true

func _initalize_container():
	if runtime_inventory.is_empty():
		runtime_inventory = default_inventory.duplicate(true)

func _ready() -> void:
	_on_ready()
	_initalize_container()
	


#func _ready() -> void:
	#wm = Global.world_manager
	#parent_layer = get_parent().get_parent()
	#current_hp = max_hp
	#pos = wm.pixels_to_tile(global_position, parent_layer.id)
	#if wm.world_ready == true:
		#initialize()
	#if runtime_inventory.is_empty():
		#runtime_inventory = default_inventory.duplicate(true)
	#SignalBus.world_ready.connect(initialize)
	#SignalBus.world_quit.connect(unregister)
