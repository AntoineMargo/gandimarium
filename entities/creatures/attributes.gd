extends Resource
class_name Attributes

@export var attributes: Dictionary = {
	Enums.Attribute.ACUITY: 6,
	Enums.Attribute.BRAWN: 6,
	Enums.Attribute.DEXTERITY: 6,
	Enums.Attribute.RESOLVE: 6
}

func get_attribute(type: Enums.Attribute) -> int:
	return attributes.get(type, 0)

func set_attribute(type: Enums.Attribute, value: int) -> void:
	attributes[type] = value
