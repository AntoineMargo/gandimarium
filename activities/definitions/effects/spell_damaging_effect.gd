extends Effect

class_name DamagingEffect

@export var dice_number: int = 2
@export var damage_die: int = 10
@export var damage_bonus: int = 0
@export var resistance: String = ""

func apply(source, target, degree: int) -> void:
	var user = source.user
	var result = degree
	var total_damage = Global.crisis_manager.determine_damage(dice_number, damage_die, damage_bonus, result)
	if target and target.char_data.has_method("take_damage"):
		target.char_data.take_damage(total_damage, resistance)
