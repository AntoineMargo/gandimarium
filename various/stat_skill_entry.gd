extends StatEntry
class_name StatSkillEntry

@export var stat: Enums.Skill

func get_stat() -> Enums.Skill:
	return stat

func get_type() -> Enums.StatType:
	return Enums.StatType.SKILL
