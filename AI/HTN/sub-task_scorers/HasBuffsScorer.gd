extends TaskScorer
class_name HasBuffsScorer

func score(report: TacticalReport) -> int:
	for entry in report.available_activities:
			var tags = entry.ai_hint.act_tags

			for tag in tags:
				if tag.tag == Enums.ActivityTag.BUFF:
					return 50

	return 0
