extends ModifierEntry
class_name SpellModifierEntry

#@export var stat: String = ""
#@export var amount: int = 0
@export var base_amount: int = 0

func get_amount(source, _target) -> int:
	return (amount * source.current_spell_rank) + base_amount
