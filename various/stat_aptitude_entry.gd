extends StatEntry
class_name StatAptitudeEntry

@export var stat: Enums.Aptitude

func get_stat() -> Enums.Aptitude:
	return stat

func get_type() -> Enums.StatType:
	return Enums.StatType.APTITUDE
