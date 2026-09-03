extends Object
class_name DerivedStats

var aptitudes: Dictionary = {
	Enums.Aptitude.SENSE: 0,
	Enums.Aptitude.STAMINA: 0,
	Enums.Aptitude.AGILITY: 0,
	Enums.Aptitude.WILL: 0,
	Enums.Aptitude.OFFENCE: 0,
	Enums.Aptitude.MELEE_DEFENCE: 0,
	Enums.Aptitude.RANGED_DEFENCE: 0
}

var skills: Dictionary = {
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
#var physical: int = 0
#var heat: int = 0
#var cold: int = 0
#var electricity: int = 0
#var corrosion: int = 0
#var poison: int = 0
#var psychic: int = 0

func get_aptitude(type: Enums.Aptitude) -> int:
	return aptitudes.get(type, 0)

func set_aptitude(type: Enums.Aptitude, value: int) -> void:
	aptitudes[type] = value

func get_skill(type: Enums.Skill) -> int:
	return skills.get(type, 0)

func set_skill(type: Enums.Skill, value: int) -> void:
	skills[type] = value

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

#func get_resistance(type: Enums.Resistance) -> int:
	#match type:
		#Enums.Resistance.NONE:
			#return 0
		#Enums.Resistance.PHYSICAL:
			#return physical
		#Enums.Resistance.HEAT:
			#return heat
		#Enums.Resistance.COLD:
			#return cold
		#Enums.Resistance.ELECTRICITY:
			#return electricity
		#Enums.Resistance.CORROSION:
			#return corrosion
		#Enums.Resistance.POISON:
			#return poison
		#Enums.Resistance.PSYCHIC:
			#return psychic
	#return 0
#
#func set_resistance(type: Enums.Resistance, value: int) -> void:
	#match type:
		#Enums.Resistance.PHYSICAL:
			#physical = value
		#Enums.Resistance.HEAT:
			#heat = value
		#Enums.Resistance.COLD:
			#cold = value
		#Enums.Resistance.ELECTRICITY:
			#electricity = value
		#Enums.Resistance.CORROSION:
			#corrosion = value
		#Enums.Resistance.POISON:
			#poison = value
		#Enums.Resistance.PSYCHIC:
			#psychic = value
