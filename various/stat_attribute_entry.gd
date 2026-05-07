extends StatEntry
class_name StatAttributeEntry

@export var stat: Enums.Attribute

func get_stat() -> Enums.Attribute:
	return stat

func get_type() -> Enums.StatType:
	return Enums.StatType.ATTRIBUTE
