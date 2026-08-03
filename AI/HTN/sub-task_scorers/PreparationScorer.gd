extends TaskScorer
class_name PreparationScorer

func score(report: TacticalReport) -> int:
	return report.crisis.preparation_utility
