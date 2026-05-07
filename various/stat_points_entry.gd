extends StatEntry
class_name StatPointsEntry

@export var stat: Enums.Point

func get_stat() -> Enums.Point:
	return stat

func get_type() -> Enums.StatType:
	return Enums.StatType.POINT
