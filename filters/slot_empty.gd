extends Filter
class_name SlotEmptyFilter

@export var slot: Enums.EquipmentSlot
@export var reverse: bool = false

func is_satisfied(context: Context) -> bool:
	if not context.target:
		return false

	var item = context.target.data.equipment.get_item_in_slot(slot)

	if item:
		return false
	else:
		return true
