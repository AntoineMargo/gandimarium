extends Activity
class_name WeaponActivity

var weapon: Item = null
var attack_types = [
	load("res://resources/damage_patterns/slash.tres"),
	load("res://resources/damage_patterns/pierce.tres"),
	load("res://resources/damage_patterns/crush.tres"),
]
@export var pattern_ids: Array[int]
#@export var attack_types: Array[DamagePattern] = []

#func _ready():
	#pattern_ids = attack_types.map(func(a): return a.id)


#func _post_init():
	#print("Attempting to build the pattern ids for the weapon.")
	#var pattern_ids = []
	#print("attack types: ", attack_types)
	#for a in attack_types:
		#print("	Found an attack type.")
		#pattern_ids.append(a.id)
	##pattern_ids = attack_types.map(func(a): return a.id)
