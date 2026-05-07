extends Resource
class_name Skills

@export var arcane: int = 0
@export var artistry: int = 0
@export var society: int = 0
@export var craftsmanship: int = 0
@export var deception: int = 0
@export var history: int = 0
@export var linguistics: int = 0
@export var mechanics: int = 0
@export var medicine: int = 0
@export var nature: int = 0
@export var persuasion: int = 0
@export var thievery: int = 0
@export var stealth: int = 0

func get_skill(type: Enums.Skill) -> int:
	match type:
		Enums.Skill.ARCANE:
			return arcane
		Enums.Skill.ARTISTRY:
			return artistry
		Enums.Skill.SOCIETY:
			return society
		Enums.Skill.CRAFTSMANSHIP:
			return craftsmanship
		Enums.Skill.DECEPTION:
			return deception
		Enums.Skill.HISTORY:
			return history
		Enums.Skill.LINGUISTICS:
			return linguistics
		Enums.Skill.MECHANICS:
			return mechanics
		Enums.Skill.MEDICINE:
			return medicine
		Enums.Skill.NATURE:
			return nature
		Enums.Skill.PERSUASION:
			return persuasion
		Enums.Skill.THIEVERY:
			return thievery
		Enums.Skill.STEALTH:
			return stealth
	return 0

func set_skill(type: Enums.Skill, value: int) -> void:
	match type:
		Enums.Skill.ARCANE:
			arcane = value
		Enums.Skill.ARTISTRY:
			artistry = value
		Enums.Skill.SOCIETY:
			society = value
		Enums.Skill.CRAFTSMANSHIP:
			craftsmanship = value
		Enums.Skill.DECEPTION:
			deception = value
		Enums.Skill.HISTORY:
			history = value
		Enums.Skill.LINGUISTICS:
			linguistics = value
		Enums.Skill.MECHANICS:
			mechanics = value
		Enums.Skill.MEDICINE:
			medicine = value
		Enums.Skill.NATURE:
			nature = value
		Enums.Skill.PERSUASION:
			persuasion = value
		Enums.Skill.THIEVERY:
			thievery = value
		Enums.Skill.STEALTH:
			stealth = value
