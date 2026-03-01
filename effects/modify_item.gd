extends Effect
class_name ModifyItemEffect

@export var condition_id: String = ""
@export var entries: Array[SpellModifierEntry] = []

func apply_context(ctx: ActivityContext) -> void:
	for item in ctx.created_items:
		for condition in item.conditions:
			if condition.id != condition_id:
				continue

			for effect in condition.effects:
				if effect is ModifierEffect:

					for i in effect.modifiers.size():
						var modifier_entry = effect.modifiers[i].duplicate(true)
						effect.modifiers[i] = modifier_entry

						for entry in entries:
							if modifier_entry.stat == entry.stat:
								modifier_entry.amount = entry.get_amount(ctx, null)

#@export var condition_id: String = ""
#@export var stat: String = ""
#@export var base_amount: int = 0
#@export var amount_to_multiply: int = 0

#func create_amount(ctx) -> int:
	#return (amount_to_multiply * ctx.current_spell_rank) + base_amount

#func apply_context(ctx: ActivityContext) -> void:
	#for item in ctx.created_items:
		#for condition in item.conditions:
			#if condition.id == condition_id:
				#for effect in condition.effects:
					#if effect is ModifierEffect:
						#for i in effect.modifiers.size():
							#var modifier_entry = effect.modifiers[i].duplicate(true)
							#effect.modifiers[i] = modifier_entry
							#if modifier_entry.stat == stat:
								#modifier_entry.amount = create_amount(ctx)






#func apply(source, target, _degree: int = 2) -> void:
	#if target is Creature:
		#var equipped_items = target.get_all_equipped_items()
		#for item in equipped_items:
			#if item.id == item_id:
				#target.remove_item_conditions(item)
				#item = item.duplicate(true)
				#for condition in item.conditions:
					#if condition.id == condition_id:
						#for effect in condition.effects:
							#if effect is ModifierEffect:
								#for modifier_entry in effect.modifiers:
									#modifier_entry = modifier_entry.duplicate(true)
									#if modifier_entry.stat == stat:
										#modifier_entry.amount = create_amount(source)
				#target.add_item_conditions(item)

#func remove(_source, target, _degree):
	#if target.has_method("get_all_equipped_items"):
		#target.get_all_equipped_items()
	#else:
		#push_error("Method doesn't exist.")
