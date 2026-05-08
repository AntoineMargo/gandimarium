extends NumericModifier
class_name SpellRankModifier

@export var starting_amount: int = 0
@export var multiplied_amount: int = 1

func modify(_value: int, ctx: Context):
	var spell_rank = ctx.user.data.current_spell_rank
	
	return starting_amount + multiplied_amount * spell_rank
