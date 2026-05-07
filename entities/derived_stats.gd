extends Object
class_name DerivedStats

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

# points
var max_hp: int = 0
var max_pp: int = 0
var max_ep: int = 0

var max_mp: int = 0
var max_ap: int = 0

var max_reactions: int = 0
var vigour: int = 0
var strength_bonus: int = 0

# others
var size: String = ""
var current_spell_cost: int = 0

var tie_breaker: float = 0.0

# resistances
var physical: int = 0
var heat: int = 0
var cold: int = 0
var electricity: int = 0
var corrosion: int = 0
var poison: int = 0
var psychic: int = 0

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

func get_points(type: Enums.Point) -> int:
	match type:
		Enums.Point.MAX_HP:
			return max_hp
		Enums.Point.MAX_PP:
			return max_pp
		Enums.Point.MAX_EP:
			return max_ep
		Enums.Point.MAX_MP:
			return max_mp
		Enums.Point.MAX_AP:
			return max_ap
		Enums.Point.MAX_RP:
			return max_reactions
		Enums.Point.VIGOUR:
			return vigour
		Enums.Point.STRENGTH:
			return strength_bonus
	return 0

func set_points(type: Enums.Point, value: int) -> void:
	match type:
		Enums.Point.MAX_HP:
			max_hp = value
		Enums.Point.MAX_PP:
			max_pp = value
		Enums.Point.MAX_EP:
			max_ep = value
		Enums.Point.MAX_MP:
			max_mp = value
		Enums.Point.MAX_AP:
			max_ap = value
		Enums.Point.MAX_RP:
			max_reactions = value
		Enums.Point.VIGOUR:
			vigour = value
		Enums.Point.STRENGTH:
			strength_bonus = value

func get_resistance(type: Enums.Resistance) -> int:
	match type:
		Enums.Resistance.NONE:
			return 0
		Enums.Resistance.PHYSICAL:
			return physical
		Enums.Resistance.HEAT:
			return heat
		Enums.Resistance.COLD:
			return cold
		Enums.Resistance.ELECTRICITY:
			return electricity
		Enums.Resistance.CORROSION:
			return corrosion
		Enums.Resistance.POISON:
			return poison
		Enums.Resistance.PSYCHIC:
			return psychic
	return 0

func set_resistance(type: Enums.Resistance, value: int) -> void:
	match type:
		Enums.Resistance.PHYSICAL:
			physical = value
		Enums.Resistance.HEAT:
			heat = value
		Enums.Resistance.COLD:
			cold = value
		Enums.Resistance.ELECTRICITY:
			electricity = value
		Enums.Resistance.CORROSION:
			corrosion = value
		Enums.Resistance.POISON:
			poison = value
		Enums.Resistance.PSYCHIC:
			psychic = value
