extends StatEntry
class_name StatResistanceEntry

@export var stat: Enums.Resistance

func get_stat() -> Enums.Resistance:
	return stat

func get_type() -> Enums.StatType:
	return Enums.StatType.RESISTANCE
