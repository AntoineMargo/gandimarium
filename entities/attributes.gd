extends Resource
class_name Attributes

@export var acuity: int = 6
@export var brawn: int = 6
@export var dexterity: int = 6
@export var resolve: int = 6

func get_attribute(type: Enums.Attribute) -> int:
	match type:
		Enums.Attribute.ACUITY:
			return acuity
		Enums.Attribute.BRAWN:
			return brawn
		Enums.Attribute.DEXTERITY:
			return dexterity
		Enums.Attribute.RESOLVE:
			return resolve
	return 0

func set_attribute(type: Enums.Attribute, value: int) -> void:
	match type:
		Enums.Attribute.ACUITY:
			acuity = value
		Enums.Attribute.BRAWN:
			brawn = value
		Enums.Attribute.DEXTERITY:
			dexterity = value
		Enums.Attribute.RESOLVE:
			resolve = value
