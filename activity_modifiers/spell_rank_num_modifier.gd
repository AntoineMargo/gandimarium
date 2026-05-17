extends NumericModifier
class_name SpellRankModifier

enum Choice {
	REPLACE_VALUE,
	ADD_TO_VALUE
}

@export var choice: Choice 
@export var starting_amount: int = 0
@export var multiplied_amount: float = 1

func modify(value: int, ctx: Context):
	var spell_rank = ctx.user.data.current_spell_rank
	
	if choice == Choice.REPLACE_VALUE:
		return starting_amount + multiplied_amount * spell_rank
	else:
		return value + starting_amount + multiplied_amount * spell_rank
