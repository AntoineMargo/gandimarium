@abstract
extends Resource
class_name StatEntry

@export var amount: float = 0
@export var spell_rank_multiplier: float = 0

func get_type() -> Enums.StatType:
	@warning_ignore("int_as_enum_without_match", "int_as_enum_without_cast")
	return -1

func get_stat() -> int:
	return -1

func get_amount(source, _target) -> float:
	if source is Creature:
		return amount + (spell_rank_multiplier * source.data.current_spell_rank)
	elif source is Condition:
		return amount + (spell_rank_multiplier * source.target.data.current_spell_rank)
	else:
		@warning_ignore("narrowing_conversion")
		return amount
