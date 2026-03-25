extends Effect
class_name CreateItemEffect

@export var item: Item = null
@export var count: int = 1

func apply_context(ctx: ActivityContext) -> void:
	var new_item = item.duplicate(true)
	new_item.count = count
	if count == -1:
		new_item.count = count * ctx.current_spell_rank
	ctx.created_items.append(new_item)
	ctx.condition.linked_items.append(new_item)

func remove(_source, _target, _degree):
	pass
