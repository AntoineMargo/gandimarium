extends StatEntry
class_name StatSizeEntry

@export var stat: Enums.Size

func get_stat() -> Enums.Size:
	return stat

func get_type() -> Enums.StatType:
	return Enums.StatType.APTITUDE
