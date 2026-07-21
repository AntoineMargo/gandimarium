extends Effect
class_name EquipItemEffect

func apply_context(ctx: Context) -> bool:
	var success: bool = false
	for item in ctx.created_items:
		if ctx.target is Creature:
			if ctx.target.equip_item(item):
				success = true
			continue
	if success:
		SignalBus.message.emit("Spell has succeeded!")
	else:
		SignalBus.message.emit("Spell has failed.")
	return true

func remove(_source, _target, _degree):
	pass
