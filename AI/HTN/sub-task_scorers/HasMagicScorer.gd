extends TaskScorer
class_name HasMagicScorer

func score(report: TacticalReport) -> int:
	if not report.creature.data.major_archetype:
		return 0
	var archetype = report.creature.data.major_archetype.type
	match archetype:
		Enums.Archetype.SCHOLASTIC_MAGE, Enums.Archetype.ASPECTED_MAGE, Enums.Archetype.PRIMAL_MAGE:
			return 100
		_:
			return 0
