extends Prop
class_name ContainerProp

@export var default_inventory = []

var runtime_inventory = []

func make_delta() -> PropDelta:
	var prop_delta = PropDelta.new()
	prop_delta.uid = uid
	prop_delta.id = id
	prop_delta.pos = pos
	prop_delta.hp = current_hp
	prop_delta.inventory = runtime_inventory
	return prop_delta

func operate():
	pass
