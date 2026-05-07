extends Effect
class_name ModifyItemEffect

## ID of the condition to modify inside the item.
@export var condition_id: String = ""
@export var entries: Array[StatEntry] = []

func apply_context(ctx: ActivityContext) -> void:
	for item in ctx.created_items:
		for condition in item.conditions:
			if condition.id != condition_id:
				continue

			for effect in condition.effects:
				if effect is ChangeStatEffect:

					for i in effect.modifiers.size():
						var modifier_entry = effect.modifiers[i].duplicate(true)
						effect.modifiers[i] = modifier_entry

						for entry in entries:
							if modifier_entry.get_type() == entry.get_type():
								if modifier_entry.get_stat() == entry.get_stat():
									modifier_entry.amount = entry.amount
									modifier_entry.multiplier = entry.multiplier

						#for entry in entries:
							#if modifier_entry.stat == entry.stat:
								#modifier_entry.amount = entry.get_amount(ctx, null)

func remove(_source, _target, _degree):
	pass
