extends Filter
class_name SlotEmptyFilter

@export var slot: String = ""
@export var reverse: bool = false

func is_satisfied(context: ActivityContext) -> bool:
	if not context.target:
		return false

	var item = context.target.get_equipment_slot(slot)

	if item:
		return false
	else:
		return true
