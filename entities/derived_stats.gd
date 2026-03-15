extends Object
class_name DerivedStats

var vigour: int = 0

# aptitudes
var sense: int = 0
var stamina: int = 0
var agility: int = 0
var will: int = 0
var offence: int = 0
var melee_defence: int = 0
var ranged_defence: int = 0

# skills
var arcane: int = 0
var artistry: int = 0
var society: int = 0
var craftsmanship: int = 0
var deception: int = 0
var history: int = 0
var linguistics: int = 0
var mechanics: int = 0
var medicine: int = 0
var nature: int = 0
var persuasion: int = 0
var thievery: int = 0
var stealth: int = 0

var size: String = ""
var strength_bonus: int = 0

var max_hp: int = 0
var max_pp: int = 0
var max_ep: int = 0

var max_mp: int = 0

var max_ap: int = 0
var max_reactions: int = 0

var current_spell_cost: int = 0

var tie_breaker: float = 0.0

func get_aptitude(type: Enums.Aptitude) -> int:
	match type:
		Enums.Aptitude.SENSE:
			return sense
		Enums.Aptitude.STAMINA:
			return stamina
		Enums.Aptitude.AGILITY:
			return agility
		Enums.Aptitude.WILL:
			return will
		Enums.Aptitude.OFFENCE:
			return offence
		Enums.Aptitude.MELEE_DEFENCE:
			return melee_defence
		Enums.Aptitude.RANGED_DEFENCE:
			return ranged_defence
	return 0

func set_aptitude(type: Enums.Aptitude, value: int) -> void:
	match type:
		Enums.Aptitude.SENSE:
			sense = value
		Enums.Aptitude.STAMINA:
			stamina = value
		Enums.Aptitude.AGILITY:
			agility = value
		Enums.Aptitude.WILL:
			will = value
		Enums.Aptitude.OFFENCE:
			offence = value
		Enums.Aptitude.MELEE_DEFENCE:
			melee_defence = value
		Enums.Aptitude.RANGED_DEFENCE:
			ranged_defence = value

func get_skill(type: Enums.Skill) -> int:
	match type:
		Enums.Aptitude.SENSE:
			return sense
		Enums.Aptitude.STAMINA:
			return stamina
		Enums.Aptitude.AGILITY:
			return agility
		Enums.Aptitude.WILL:
			return will
		Enums.Aptitude.OFFENCE:
			return offence
		Enums.Aptitude.MELEE_DEFENCE:
			return melee_defence
		Enums.Aptitude.RANGED_DEFENCE:
			return ranged_defence
	return 0

func set_skill(type: Enums.Skill, value: int) -> void:
	match type:
		Enums.Aptitude.SENSE:
			sense = value
		Enums.Aptitude.STAMINA:
			stamina = value
		Enums.Aptitude.AGILITY:
			agility = value
		Enums.Aptitude.WILL:
			will = value
		Enums.Aptitude.OFFENCE:
			offence = value
		Enums.Aptitude.MELEE_DEFENCE:
			melee_defence = value
		Enums.Aptitude.RANGED_DEFENCE:
			ranged_defence = value
