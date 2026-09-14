extends Modifier
class_name SpellCostModifier

@export var delta: int = 0

func modify(_value: int, ctx: Context):
	var spell_rank: int = 0
	if ctx is ActivityContext:
		spell_rank = ctx.spell_rank
	else:
		spell_rank = ctx.user.data.current_spell_rank
		
	spell_rank += delta

	return ctx.user.get_spell_cost(spell_rank)
