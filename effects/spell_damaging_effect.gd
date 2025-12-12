extends Effect

class_name SpellDamagingEffect

@export var dice_number: int = 1
@export var damage_die: int = 8
@export var damage_bonus: int = 50
@export var resistance: String = ""

func apply(source, target, degree: int) -> void:
	var user = source.user
	var result = degree
	dice_number *= source.user.data.current_spell_rank
	var total_damage = Global.crisis_manager.determine_damage(dice_number, damage_die, damage_bonus, result)
	if target and target.has_method("take_damage"):
		target.take_damage(total_damage, resistance)
