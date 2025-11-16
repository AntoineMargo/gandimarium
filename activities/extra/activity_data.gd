extends Resource
class_name ActivityData

var user: Node
var target: Node
var weapon: Weapon = null
var offhand: Weapon = null
var user_stat: String
var target_stat: String
var resistance: String

var dice_number: int = 0
var damage_die: int = 0
var damage_bonus: int = 0

var attack_range: int = 0
var attack_type: int = 0

func _init(u: Node, t: Node, use_weapon := false) -> void:
	user = u
	target = t
	if use_weapon:
		_populate_weapon_data()

func _populate_weapon_data() -> void:
	var weapons = user.data.get_active_weapons()
	if weapons.is_empty():
		weapon = Library.get_item("wpn_fist")
	weapon = weapons[0]
	offhand = weapons[1]
	
	if weapon:
		dice_number = weapon.dice_number
		damage_die = weapon.damage_die
		damage_bonus = weapon.damage_bonus + user.data.strength_bonus

		attack_range = weapon.melee_range
		attack_type = user.data.get_active_attack_type()
	
		if attack_type == 0:
			attack_type = weapon.attack_type[0]
		
