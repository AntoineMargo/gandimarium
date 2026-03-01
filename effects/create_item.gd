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



	#if ctx.target is Creature:
		#ctx.target.data.inventory.add_item(new_item)
	#if ctx.target is Prop:
		#ctx.target.inventory.add_item(new_item)

#func apply(source, target, _degree: int = 2) -> void:
	#var new_item = item.duplicate()
	#if target is Creature:
		#target.data.inventory.add_item(new_item)
	#if target is Prop:
		#target.inventory.add_item(new_item)

#func remove(_source, target, _degree):
	#if target.has_method("unequip_slot"):
		#target.unequip_slot(slot)
