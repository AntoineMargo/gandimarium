extends Effect
class_name EquipItemEffect

@export var slot: String = ""

func apply_context(ctx: ActivityContext) -> void:
	for item in ctx.created_items:
		if slot:
			if ctx.target is Creature:
				ctx.target.equip_item(slot, item)
		else:
			if ctx.target is Creature:
				ctx.target.data.inventory.add_item(item)
			if ctx.target is Prop:
				ctx.target.inventory.add_item(item)


#func apply(_source, target, _degree: int = 2) -> void:
	#var new_item = item.duplicate()
	#if target.has_method("equip_item"):
		#target.equip_item(slot, new_item)
#
#func remove(_source, target, _degree):
	#if target.has_method("unequip_slot"):
		#target.unequip_slot(slot)
