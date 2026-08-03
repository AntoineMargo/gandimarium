extends TaskScorer
class_name DamageScorer

func score(report: TacticalReport) -> int:
	if report.crisis.closest_enemy:
		return 50
	else:
		return 0
