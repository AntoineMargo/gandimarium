extends Filter
class_name BothHandsFreeFilter

func is_satisfied(context: Context) -> bool:
	if not context.target:
		return false

	var left_hand = context.user.data.equipment.get_item_in_slot(Enums.EquipmentSlot.HAND_LEFT)
	var right_hand = context.user.data.equipment.get_item_in_slot(Enums.EquipmentSlot.HAND_RIGHT)

	if left_hand != null or right_hand != null:
		return false
	
	return true
