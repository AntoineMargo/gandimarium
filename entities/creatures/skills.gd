extends Resource
class_name Skills

@export var skills: Dictionary = {
	Enums.Skill.ARCANE: 0,
	Enums.Skill.ARTISTRY: 0,
	Enums.Skill.SOCIETY: 0,
	Enums.Skill.CRAFTSMANSHIP: 0,
	Enums.Skill.DECEPTION: 0,
	Enums.Skill.HISTORY: 0,
	Enums.Skill.LINGUISTICS: 0,
	Enums.Skill.MECHANICS: 0,
	Enums.Skill.MEDICINE: 0,
	Enums.Skill.NATURE: 0,
	Enums.Skill.PERSUASION: 0,
	Enums.Skill.THIEVERY: 0,
	Enums.Skill.STEALTH: 0
}

func get_skill(type: Enums.Skill) -> int:
	return skills.get(type, 0)

func set_skill(type: Enums.Skill, value: int) -> void:
	skills[type] = value
