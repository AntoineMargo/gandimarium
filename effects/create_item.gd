extends Effect
class_name CreateItemEffect

@export var item: Item = null
@export var count: int = 1

func apply_context(ctx: Context) -> bool:
	var new_item: Item = item.duplicate(true)
	new_item.count = count
	new_item.uid = Global.state_manager.next_uid(Enums.UIDType.ITEM)
	if count == -1:
		new_item.count = count * ctx.current_spell_rank
	ctx.created_items.append(new_item)
	if ctx.condition == null:
		push_error("Items must be created from inside a condition!")
	ctx.condition.linked_items.append(new_item)
	return true

func remove(_source, _target, _degree):
	pass
