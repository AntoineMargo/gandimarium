extends Effect
class_name StoreItemEffect

func apply_context(ctx: ActivityContext) -> void:
	for item in ctx.created_items:
		if ctx.target is Creature or ctx.target is ContainerProp:
			ctx.target.add_item_to_inventory(item)

func remove(_source, _target, _degree):
	pass
