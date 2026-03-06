extends Effect

class_name SpellDamagingEffect

@export var dice_number: int = 1
@export var damage_die: int = 8
@export var damage_bonus: int = 0
@export var resistance: Enums.Resistance = Enums.Resistance.NONE
@export var damage_pattern: DamagePattern = null

func apply(source, target, degree: int = 2) -> void:
	if damage_pattern == null:
		damage_pattern = Library.get_dmg_pattern("default")
	var user = source.user
	var dice_n = dice_number
	dice_n *= source.user.data.current_spell_rank

	var total_damage = CombatMath.determine_damage(
		dice_n, damage_die,
		damage_bonus, degree,
		damage_pattern)
	if target and target.has_method("take_damage"):
		target.take_damage(total_damage, resistance)
