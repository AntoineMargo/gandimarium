extends Resource
class_name Resistances

var physical: int = 0
var heat: int = 0
var cold: int = 0
var electricity: int = 0
var corrosion: int = 0
var poison: int = 0
var psychic: int = 0

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
