extends Effect

class_name DamageEffect

@export var dice_number: int = 2
@export var damage_die: int = 10
@export var damage_bonus: int = 0
@export var resistance: Enums.Resistance = Enums.Resistance.NONE
@export var damage_pattern: DamagePattern = null

func apply(_source, target, degree: int = 2) -> void:
	if damage_pattern == null:
		damage_pattern = Library.get_dmg_pattern("default")
	var total_damage = BasicMath.determine_damage(
		dice_number, damage_die,
		damage_bonus, degree,
		damage_pattern)
	if target and target.has_method("take_damage"):
		target.take_damage(total_damage, resistance)
