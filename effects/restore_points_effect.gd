extends Effect
class_name RestorePointsEffect

enum Type {
	HEALTH_POINTS,
	POWER_POINTS
}

@export var type: Type = Type.HEALTH_POINTS
@export var dice_number: int = 2
@export var dice_size: int = 10
@export var bonus: int = 0

func apply_context(ctx: Context) -> bool:
	var total_amount = BasicMath.determine_damage(dice_number, dice_size, bonus, 1)
	if ctx.target:
		match type:
			Type.HEALTH_POINTS:
				if ctx.target.has_method("restore_hp"):
					ctx.target.restore_hp(total_amount)
			Type.POWER_POINTS:
				if ctx.target.has_method("restore_pp"):
					ctx.target.restore_pp(total_amount)
	return true
