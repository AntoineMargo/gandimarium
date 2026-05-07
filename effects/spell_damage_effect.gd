extends Effect

class_name SpellDamageEffect

@export var die_number: int = 1
@export var die_size: int = 8
@export var damage_bonus: int = 0
@export var resistance: Enums.Resistance = Enums.Resistance.NONE
@export var damage_pattern: DamagePattern = null

func apply(_source, _target, _degree: int = 2) -> void:
	pass

func apply_context(ctx: ActivityContext) -> void:
	if damage_pattern == null:
		damage_pattern = Library.get_dmg_pattern("default")
	var user = ctx.user

	var final_die_size = ctx.activity.modify_value(die_size, Enums.ValueType.DIE_SIZE, ctx, Enums.ActivityStage.EFFECT)
	var final_damage_bonus = ctx.activity.modify_value(damage_bonus, Enums.ValueType.BONUS_DAMAGE, ctx, Enums.ActivityStage.EFFECT)
	var final_resistance = ctx.activity.modify_value(resistance, Enums.ValueType.RESISTANCE, ctx, Enums.ActivityStage.EFFECT)
	var final_damage_pattern = ctx.activity.modify_value(damage_pattern, Enums.ValueType.DAMAGE_PATTERN, ctx, Enums.ActivityStage.EFFECT)
	var final_die_number = ctx.activity.modify_value(die_number, Enums.ValueType.DIE_NUMBER, ctx, Enums.ActivityStage.EFFECT)

	final_die_number *= ctx.user.data.current_spell_rank

	var total_damage = BasicMath.determine_damage(
		final_die_number, final_die_size,
		final_damage_bonus, ctx.degree,
		final_damage_pattern)

	var final_total_damage = ctx.activity.modify_value(total_damage, Enums.ValueType.TOTAL_DAMAGE, ctx, Enums.ActivityStage.EFFECT)

	if ctx.target and ctx.target.has_method("take_damage"):
		ctx.target.take_damage(final_total_damage, final_resistance)
