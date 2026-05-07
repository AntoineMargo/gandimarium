@abstract
extends Resource
class_name StatEntry

@export var amount: int = 0
@export var multiplier: int = 0

func get_type() -> Enums.StatType:
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	return -1

func get_stat() -> int:
	return -1

func get_amount(source, _target) -> int:
	if source is Creature:
		return amount + (multiplier * source.data.current_spell_rank)
	elif source is Condition:
		return amount + (multiplier * source.target.data.current_spell_rank)
	else:
		return amount
