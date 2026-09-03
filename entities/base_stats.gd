extends Resource
class_name BaseStats

var level_mod: int = 0

@export var aptitudes: Dictionary = {
	Enums.Aptitude.SENSE: 0,
	Enums.Aptitude.STAMINA: 0,
	Enums.Aptitude.AGILITY: 0,
	Enums.Aptitude.WILL: 0,
	Enums.Aptitude.OFFENCE: 0,
	Enums.Aptitude.MELEE_DEFENCE: 0,
	Enums.Aptitude.RANGED_DEFENCE: 0
}

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

@export var size: String = ""
@export var strength_bonus: int = 0

@export var max_hp: int = 0
@export var max_pp: int = 0
@export var max_ep: int = 0

@export var max_mp: int = 0
@export var max_ap: int = 3
@export var max_reactions: int = 1

func get_aptitude(type: Enums.Aptitude) -> int:
	return aptitudes.get(type, 0)

func set_aptitude(type: Enums.Aptitude, value: int) -> void:
	aptitudes[type] = value

func get_skill(type: Enums.Skill) -> int:
	return skills.get(type, 0)

func set_skill(type: Enums.Skill, value: int) -> void:
	skills[type] = value
