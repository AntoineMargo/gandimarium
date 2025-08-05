extends Effect

class_name HealingEffect

@export var dice_number: int = 2
@export var healing_die: int = 10
@export var healing_bonus: int = 0

func apply(source, target, degree: int) -> void:
	var user = source.user
	var result = degree
	var total_healing = Global.combat_manager.determine_damage(dice_number, healing_die, healing_bonus, result)
	if target and target.has_method("take_healing"):
		target.take_healing(total_healing)
