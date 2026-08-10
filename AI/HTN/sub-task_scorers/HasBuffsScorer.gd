extends TaskScorer
class_name HasBuffsScorer

func score(report: TacticalReport) -> int:
	var buff: bool
	var permanent: bool
	for entry in report.available_activities:
		var tags = entry.ai_hint.act_tags
		buff = false
		permanent = false

		for tag in tags:
			if tag.tag == Enums.ActivityTag.BUFF:
				buff = true
			if tag.tag == Enums.ActivityTag.PERMANENT:
				permanent = true
		
		if buff and not permanent:
			return 50

	return 0
