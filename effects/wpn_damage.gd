extends Effect

class_name WeaponDamageEffect

@export var dice_number: int = 2
@export var damage_die: int = 10
@export var damage_bonus: int = 0
@export var resistance: String = "physical"
@export var damage_pattern: DamagePattern = null

func apply(source, target, degree: int) -> void:
	if damage_pattern == null:
		damage_pattern = source.attack_types[source.attack_type]
	var total_damage = CombatMath.determine_damage(
		dice_number, damage_die,
		damage_bonus, degree,
		damage_pattern)
	if target and target.data.has_method("take_damage"):
		target.data.take_damage(total_damage, resistance)
