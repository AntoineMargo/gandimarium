extends Effect
class_name CreateItemEffect

@export var item: ItemContainer = null

func apply_context(ctx: Context) -> bool:
	var new_item: ItemContainer = item.duplicate(true)
	new_item.uid = Global.state_manager.next_uid(Enums.UIDType.ITEM)
	Global.state_manager.register_item_container(new_item)
	ctx.created_items.append(new_item)
	if ctx.condition == null:
		push_error("Items must be created from inside a condition!")
	ctx.condition.linked_items.append(new_item)
	return true

func remove(_source, _target, _degree):
	pass
