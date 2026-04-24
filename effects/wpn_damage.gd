extends Effect
class_name WeaponDamageEffect

@export var die_number: int = 2
@export var die_size: int = 10
@export var damage_bonus: int = 0
@export var resistance: Enums.Resistance = Enums.Resistance.NONE

func apply(_source, _target, _degree: int = 2) -> void:
	pass

func apply_context(ctx: ActivityContext) -> void:
	var category = ctx.user.data.equipment.active_category

	var chosen_attack_type = -1
	if category == Enums.AttackCategory.STRIKE:
		chosen_attack_type = ctx.activity.weapon.selected_attacks[Enums.AttackCategory.STRIKE]
	elif category == Enums.AttackCategory.SHOOT:
		chosen_attack_type = ctx.activity.weapon.selected_attacks[Enums.AttackCategory.SHOOT]
	elif category == Enums.AttackCategory.THROW:
		chosen_attack_type = ctx.activity.weapon.selected_attacks[Enums.AttackCategory.THROW]
	
	var damage_pattern: DamagePattern = null
	
	for pattern in ctx.activity.attack_types:
		if pattern.id == chosen_attack_type:
			damage_pattern = pattern
			break
	if damage_pattern == null:
		damage_pattern = Library.get_dmg_pattern("default")
	
	damage_bonus += ctx.user.get_final_stat("brawn")
	
	var final_die_size = ctx.activity.modify_value(die_size, Enums.ValueType.DIE_SIZE, ctx, Enums.ActivityStage.EFFECT)
	var final_damage_bonus = ctx.activity.modify_value(damage_bonus, Enums.ValueType.BONUS_DAMAGE, ctx, Enums.ActivityStage.EFFECT)
	var final_resistance = ctx.activity.modify_value(resistance, Enums.ValueType.RESISTANCE, ctx, Enums.ActivityStage.EFFECT)
	var final_damage_pattern = ctx.activity.modify_value(damage_pattern, Enums.ValueType.DAMAGE_PATTERN, ctx, Enums.ActivityStage.EFFECT)
	var final_die_number = ctx.activity.modify_value(die_number, Enums.ValueType.DIE_NUMBER, ctx, Enums.ActivityStage.EFFECT)

	var total_damage = BasicMath.determine_damage(
		final_die_number, final_die_size,
		final_damage_bonus, ctx.degree,
		final_damage_pattern)
		
	var final_total_damage = ctx.activity.modify_value(total_damage, Enums.ValueType.TOTAL_DAMAGE, ctx, Enums.ActivityStage.EFFECT)

	if ctx.target and ctx.target.has_method("take_damage"):
		ctx.target.take_damage(final_total_damage, final_resistance)
	print("damage done (before armour): %d" % total_damage)


#func apply(source, target, degree: int = 2) -> void:
	#var category = source.user.data.equipment.active_category
#
	#var chosen_attack_type = -1
	#if category == Enums.AttackCategory.STRIKE:
		#chosen_attack_type = source.weapon.selected_attacks[Enums.AttackCategory.STRIKE]
	#elif category == Enums.AttackCategory.SHOOT:
		#chosen_attack_type = source.weapon.selected_attacks[Enums.AttackCategory.SHOOT]
	#elif category == Enums.AttackCategory.THROW:
		#chosen_attack_type = source.weapon.selected_attacks[Enums.AttackCategory.THROW]
	#
	#var damage_pattern: DamagePattern = null
	#
	#for pattern in source.attack_types:
		#if pattern.id == chosen_attack_type:
			#damage_pattern = pattern
			#break
	#if damage_pattern == null:
		#damage_pattern = Library.get_dmg_pattern("default")
	#
	#damage_bonus += source.user.get_final_stat("brawn")
	#
	#var total_damage = BasicMath.determine_damage(
		#dice_number, die_size,
		#damage_bonus, degree,
		#damage_pattern)
	#if target and target.has_method("take_damage"):
		#target.take_damage(total_damage, resistance)
	#print("damage done (before armour): %d" % total_damage)
