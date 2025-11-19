extends Item

class_name Weapon

@export var dice_number: int = 2
@export var damage_die: int = 8
@export var melee_range: int = 1
@export var damage_bonus: int = 0
@export var throw_increment: int = 10
@export var brawn_req_1h : int = 4
@export var brawn_req_2h : int = 2
@export var attack_type : Array = []

@export var attack_types : Array[DamagePattern] = []
