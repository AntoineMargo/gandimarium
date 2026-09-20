extends Effect
class_name SpellMatrixEffect

@export var modifiers: Array[Modifier] = []

func apply_context(ctx: ActivityContext) -> bool:
	if ctx.activity is not ImmediateActivity:
		return false
	
	var target = ctx.user
	var spell_rank = ctx.spell_rank

	var spell_act: Activity = ctx.activity.prompt_result["chosen_spell"]
	

	for modifier in modifiers:
		spell_act.modifiers.append(modifier)
	
	#var spell_rank_modifier: ReplaceModifier = ReplaceModifier.new()
	var spell_rank_modifier: ReplaceModifier = load("res://resources/activity_modifiers/spell_rank_replacer.tres").duplicate(true)
	spell_rank_modifier.replace_by = spell_rank
	spell_act.modifiers.append(spell_rank_modifier)

	var remove_spell_cost_mod: Modifier = load("res://resources/activity_modifiers/set_spell_cost_to_0.tres")
	spell_act.modifiers.append(remove_spell_cost_mod)

	var activity_variant: ActivityVariant = ActivityVariant.new(spell_act)
	var activity_container: ActivityContainer = ActivityContainer.new(spell_act.name, spell_act.description, spell_act.icon, [activity_variant])
	target.add_activity(activity_container)
	
	if ctx is ActivityContext and ctx.condition:
		ctx.condition.linked_activities.append(activity_container)
	#if ctx is ActivityContext and ctx.condition:
		#ctx.condition.linked_activities.append(spell_act)
	return true
