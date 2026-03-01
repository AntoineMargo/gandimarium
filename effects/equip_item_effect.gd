extends Effect
class_name EquipItemEffect

@export var item: Item = null
@export var slot: String = ""

func apply(_source, target, _degree: int = 2) -> void:
	var new_item = item.duplicate()
	if target.has_method(" equip_item"):
		target.equip_item(slot, new_item)

func remove(_source, target, _degree):
	if target.has_method("unequip_slot"):
		target.unequip_slot(slot)
